//
//  AppManager.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import CoreLocation

protocol AppManagerDelegate: AnyObject {
    func passErrorToClient(_ error: AppKit.AppError)
    func didReceiveAppDatas(_ appDatas: [AppKit.AppData])
    func didEscapeForecourt(_ appDatas: [AppKit.AppData])
    func didEnterGeofence(with id: String)
    func didExitGeofence(with id: String)
    func didFailToMonitorRegion(_ region: CLRegion, error: Error)
}

class AppManager {
    weak var delegate: AppManagerDelegate?

    private var locationProvider: AppDrawerLocationProvider
    private var isLocationFetchRunning = false
    private var isGeneralFetchRunning = false

    private var currentlyDisplayedApps: (apps: [AppKit.AppData], location: CLLocation)?

    init() {
        locationProvider = AppDrawerLocationProvider()
        locationProvider.delegate = self
    }

    func setConfigValues() {
        locationProvider.lowAccuracy = PACECloudSDK.shared.config?.allowedLowAccuracy ?? Constants.Configuration.defaultAllowedLowAccuracy
    }

    func startRetrievingLocation() {
        locationProvider.startFetchingLocation()
    }
}

// MARK: - API requests
extension AppManager {
    private func cofuGasStations(for location: CLLocation, completion: @escaping ([AppKit.AppData]?) -> Void) {
        POIKit.locationBasedCofuStations(for: location) { [weak self] result in
            switch result {
            case .failure(let error):
                switch error {
                case .requestCancelled, .invalidSpeed:
                    completion(nil)

                default:
                    self?.fetchAppsByLocation(with: location, completion: completion)
                }

            case .success(let stations):
                let appDatas = self?.retrieveAppData(from: stations)
                completion(appDatas)
            }
        }
    }

    private func fetchAppsByLocation(with location: CLLocation, completion: @escaping (([AppKit.AppData]?) -> Void)) {
        guard !isLocationFetchRunning else {
            completion(nil)
            delegate?.passErrorToClient(.fetchAlreadyRunning)
            return
        }

        let lat: Float = Float(location.coordinate.latitude)
        let lon: Float = Float(location.coordinate.longitude)

        AppKitLogger.i("[AppManager] Fetching Apps for location: \(lat), \(lon)")

        isLocationFetchRunning = true

        let apiRequest = POIAPI.Apps.CheckForPaceApp.Request(filterlatitude: lat, filterlongitude: lon)
        API.POI.client.makeRequest(apiRequest) { [weak self] apiResult in
            defer {
                self?.isLocationFetchRunning = false
                self?.locationProvider.locationManager.stopUpdatingLocation()
            }

            switch apiResult.result {
            case .success(let response):
                guard let appsResponse = response.success?.data else {
                    AppKitLogger.e("[AppManager] Response doesn't contain any data")
                    completion(nil)
                    return
                }

                let appDatas: [AppKit.AppData] = appsResponse.reduce(into: []) { result, app in
                    guard let id = app.id, let attributes = app.attributes, let gasStationReferences = attributes.references else {
                        return
                    }

                    // In case if the identical app contains multiple gas station references
                    let appDatas: [AppKit.AppData] = gasStationReferences.map {
                        let metadata: [AppKit.AppMetadata: AnyHashable] = [AppKit.AppMetadata.appId: app.id, AppKit.AppMetadata.references: [$0]]
                        let appData = AppKit.AppData(appID: id, appUrl: attributes.pwaUrl, metadata: metadata)
                        return appData
                    }

                    result.append(contentsOf: appDatas)
                }

                completion(appDatas)

            case .failure(let error):
                AppKitLogger.e("[AppManager] failed fetching local apps with error \(error)")
                completion(nil)
                self?.delegate?.passErrorToClient(.couldNotFetchApp)
            }
        }
    }

    func fetchListOfApps(completion: @escaping (([AppKit.AppData]?, AppKit.AppError?) -> Void)) {
        guard !isGeneralFetchRunning else {
            completion(nil, .fetchAlreadyRunning)
            return
        }

        isGeneralFetchRunning = true
        let apiRequest = POIAPI.Apps.GetApps.Request()
        API.POI.client.makeRequest(apiRequest) { [weak self] apiResult in
            defer {
                self?.isGeneralFetchRunning = false
            }

            switch apiResult.result {
            case .success(let response):
                guard let apps = response.success?.data else {
                    completion(nil, .couldNotFetchApp)
                    return
                }

                var appDatas: [AppKit.AppData] = []

                for app in apps {
                    guard let id = app.id, let attributes = app.attributes else {
                        continue
                    }

                    let metadata: [AppKit.AppMetadata: AnyHashable] = [AppKit.AppMetadata.appId: app.id]

                    let appData = AppKit.AppData(appID: id,
                                          title: attributes.title,
                                          subtitle: attributes.subtitle,
                                          appUrl: attributes.pwaUrl,
                                          metadata: metadata)

                    appDatas.append(appData)
                }

                completion(appDatas, nil)

            case .failure(let error):
                AppKitLogger.e("[AppManager] failed fetching list of apps with error \(error)")
                completion(nil, .other(error))
            }
        }
    }

    private func fetchAppManifest(with appDatas: [AppKit.AppData]) {
        let dispatchGroup = DispatchGroup()
        for appData in appDatas {
            guard let manifestUrlString = URLBuilder.buildAppManifestUrl(with: appData.appBaseUrl) else {
                AppKitLogger.e("[AppManager] Manifest url string nil")
                return
            }

            var localizationHeader: [String: String]?
            if let currentLanguageCode = AppKit.Constants.currentLanguageCode {
                localizationHeader = [HttpHeaderFields.acceptLanguage.rawValue: currentLanguageCode]
            }

            dispatchGroup.enter()
            URLDataRequest.requestJson(with: manifestUrlString, expectedType: AppManifest.self, headers: localizationHeader) { result in
                defer {
                    dispatchGroup.leave()
                }

                switch result {
                case .failure(let error):
                    AppKitLogger.e("[AppManager] Failed fetching app (with gas station id \(appData.poiId)) manifest with error: \(String(describing: error))")
                    return

                case .success(let manifest):
                    appData.appManifest = manifest
                    appData.appManifest?.manifestUrl = manifestUrlString

                    guard let decomposedValues = URLDecomposer.decomposeManifestUrl(with: appData.appManifest, appBaseUrl: appData.appBaseUrl) else { return }
                    let references = (appData.metadata[AppKit.AppMetadata.references] as? [String])?.first
                    appData.appStartUrl = URLBuilder.buildAppStartUrl(with: decomposedValues.url, decomposedParams: decomposedValues.params, references: references)
                }
            }
        }

        dispatchGroup.notify(queue: DispatchQueue.main) {
            let validAppDatas = appDatas.filter { $0.appManifest != nil && $0.appStartUrl != nil }
            guard !validAppDatas.isEmpty else { return }
            self.delegate?.didReceiveAppDatas(validAppDatas)
        }
    }
}

extension AppManager {
    func buildAppUrl(with appUrl: String, for reference: String) -> String? {
        URLBuilder.buildAppStartUrl(with: appUrl, decomposedParams: [.references], references: reference)
    }

    private func retrieveAppData(from cofuGasStations: [POIKit.CofuGasStation]) -> [AppKit.AppData] {
        let appDatas: [AppKit.AppData] = cofuGasStations.reduce(into: []) { result, station in
            let metadata: [AppKit.AppMetadata: AnyHashable] = [AppKit.AppMetadata.references: [station.id]]
            let appDatas: [AppKit.AppData] = (station.properties["apps"] as? [[String: Any]] ?? []).map { app in
                let appData = AppKit.AppData(appID: nil, appUrl: app["url"] as? String ?? "", metadata: metadata)
                return appData
            }
            result.append(contentsOf: appDatas)
        }

        return appDatas
    }

    private func process(appDatas: [AppKit.AppData], location: CLLocation) {
        let newGasStationIds = appDatas.map { $0.poiId }
        removeDisplayedAppsIfNeeded(with: newGasStationIds)
        currentlyDisplayedApps = (apps: appDatas, location: location)
        fetchAppManifest(with: appDatas)
    }

    private func removeDisplayedAppsIfNeeded(with newApps: [String]) {
        let appsToRemove = currentlyDisplayedApps?.apps.filter { !newApps.contains($0.poiId) } ?? []

        guard !appsToRemove.isEmpty else { return }

        removeDisplayedApps(with: appsToRemove)
        delegate?.didEscapeForecourt(appsToRemove)
    }

    private func removeDisplayedApps(with apps: [AppKit.AppData]) {
        apps.forEach {
            NotificationCenter.default.post(name: .appEventOccured, object: AppKit.AppEvent.escapedForecourt(gasStationId: $0.poiId))
        }
    }
}

extension AppManager: AppDrawerLocationProviderDelegate {
    func didEnterGeofence(with id: String) {
        delegate?.didEnterGeofence(with: id)
    }

    func didExitGeofence(with id: String) {
        delegate?.didExitGeofence(with: id)
    }

    func didFailToMonitorRegion(_ region: CLRegion, error: Error) {
        delegate?.didFailToMonitorRegion(region, error: error)
    }

    func setupGeofenceRegions(for locations: [String: CLLocationCoordinate2D]) {
        AppKitLogger.i("[App Manager] Start setting up geofence regions")

        resetGeofences()
        locationProvider.monitorRegionsAt(locations: locations)
    }

    func resetGeofences() {
        locationProvider.resetGeofences()
    }

    func didReceiveLocation(_ location: CLLocation) {
        AppKitLogger.i("[App Manager] Did receive location. Checking for available apps...")

        cofuGasStations(for: location) { [weak self] appDatas in
            guard let appDatas = appDatas else { return }
            self?.process(appDatas: appDatas, location: location)
        }
    }

    func didFailWithError(_ error: Error) {
        AppKitLogger.e("[App Manager] Couldn't retrieve location because of \(error)")

        if locationProvider.locationManager.location == nil {
            delegate?.passErrorToClient(.other(error))
        }

        // Reduced Accuracy -> Remove current app drawers
        if let error = error as? CLError, error.code == .deferredAccuracyTooLow {
            removeDisplayedApps(with: currentlyDisplayedApps?.apps ?? [])
            currentlyDisplayedApps = nil
            delegate?.passErrorToClient(.other(error))
        }
    }
}
