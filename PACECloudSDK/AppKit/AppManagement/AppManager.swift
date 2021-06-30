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
    private var geoAPIManager: GeoAPIManager
    private var isLocationFetchRunning = false
    private var isGeneralFetchRunning = false

    private var currentlyDisplayedApps: (apps: [AppKit.AppData], location: CLLocation)?
    private var currentlyDisplayedAppsRemovalThreshold: CLLocationDistance = 150

    private lazy var oneTimeLocationProvider: OneTimeLocationProvider = .init()

    init() {
        locationProvider = AppDrawerLocationProvider()
        geoAPIManager = GeoAPIManager()

        locationProvider.delegate = self
    }

    func setConfigValues() {
        locationProvider.lowAccuracy = PACECloudSDK.shared.config?.allowedLowAccuracy ?? Constants.Configuration.defaultAllowedLowAccuracy
        oneTimeLocationProvider.lowAccuracy = PACECloudSDK.shared.config?.allowedLowAccuracy ?? Constants.Configuration.defaultAllowedLowAccuracy
        geoAPIManager.speedThreshold = PACECloudSDK.shared.config?.speedThreshold ?? Constants.Configuration.defaultSpeedThreshold
        geoAPIManager.geoAppsScope = PACECloudSDK.shared.config?.geoAppsScope ?? Constants.Configuration.defaultGeoAppsScope
    }

    func startRetrievingLocation() {
        locationProvider.startFetchingLocation()
    }

    func isPoiInRange(with id: String, completion: @escaping (Bool) -> Void) {
        DispatchQueue.main.async { [weak self] in
            self?.oneTimeLocationProvider.requestLocation { [weak self] location in
                guard let location = location else {
                    completion(false)
                    return
                }

                self?.geoAPIManager.isPoiInRange(with: id, near: location, completion: completion)
            }
        }
    }

    func cofuGasStations(option: AppKit.CofuGasStation.Option, completion: @escaping ([AppKit.CofuGasStation]?) -> Void) {
        geoAPIManager.cofuGasStations(option: option) { result in
            guard case let .success(stations) = result else {
                completion(nil)
                return
            }
            completion(stations)
        }
    }
}

// MARK: - API requests
extension AppManager {
    private func cofuGasStations(for location: CLLocation, completion: @escaping ([AppKit.CofuGasStation]?) -> Void) {
        geoAPIManager.cofuGasStations(for: location) { [weak self] result in
            switch result {
            case .failure(let error):
                switch error {
                case .requestCancelled, .invalidSpeed:
                    completion(nil)

                default:
                    self?.fetchAppsByLocation(with: location, completion: completion)
                }

            case .success(let stations):
                completion(stations)
            }
        }
    }

    private func fetchAppsByLocation(with location: CLLocation, completion: @escaping (([AppKit.CofuGasStation]?) -> Void)) {
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

                let cofuStations: [AppKit.CofuGasStation] = appsResponse.reduce(into: []) { result, app in
                    guard let gasStationReferences = app.attributes?.references, let url = app.attributes?.pwaUrl else { return }

                    let apps: [AppKit.CofuGasStation] = gasStationReferences.map { reference in
                        .init(id: reference, coordinates: nil, polygon: nil, properties: ["apps": ["url": url]])
                    }

                    result.append(contentsOf: apps)
                }

                completion(cofuStations)

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

    private func retrieveAppData(for cofuGasStations: [AppKit.CofuGasStation], with location: CLLocation) {
        let appDatas: [AppKit.AppData] = cofuGasStations.reduce(into: []) { result, station in
            let metadata: [AppKit.AppMetadata: AnyHashable] = [AppKit.AppMetadata.references: [station.id]]
            let appDatas: [AppKit.AppData] = (station.properties["apps"] as? [[String: Any]] ?? []).map { app in
                let appData = AppKit.AppData(appID: nil, appUrl: app["url"] as? String ?? "", metadata: metadata)
                return appData
            }
            result.append(contentsOf: appDatas)
        }

        process(appDatas: appDatas, location: location)
    }

    private func process(appDatas: [AppKit.AppData], location: CLLocation) {
        if appDatas.isEmpty,
           let currentLocation = currentlyDisplayedApps?.location,
           currentLocation.distance(from: location) < currentlyDisplayedAppsRemovalThreshold {
            // If the new location returns no apps and
            // it's not farther away than 150 from the previous location
            // we keep the current apps
            return
        }

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

        cofuGasStations(for: location) { [weak self] apps in
            guard let apps = apps else { return }
            self?.retrieveAppData(for: apps, with: location)
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
