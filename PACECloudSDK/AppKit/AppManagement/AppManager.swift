//
//  AppManager.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import CoreLocation

protocol AppManagerDelegate: class {
    func passErrorToClient(_ error: AppKit.AppError)
    func didReceiveAppDatas(_ appDatas: [AppKit.AppData])
    func didEscapeForecourt(_ appDatas: [AppKit.AppData])
    func didEnterGeofence(with id: String)
    func didExitGeofence(with id: String)
    func didFailToMonitorRegion(_ region: CLRegion, error: Error)
    func didReceiveAppReferences(_ references: [String])
}

class AppManager {
    weak var delegate: AppManagerDelegate?

    private var locationProvider: AppDrawerLocationProvider
    private var geoAPIManager: GeoAPIManager
    private var isLocationFetchRunning = false
    private var isGeneralFetchRunning = false
    private var currentlyDisplayedLocationApps: [AppKit.AppData] = []

    private lazy var oneTimeLocationProvider: OneTimeLocationProvider = .init()

    init() {
        locationProvider = AppDrawerLocationProvider()
        geoAPIManager = GeoAPIManager()

        locationProvider.delegate = self
    }

    func setConfigValues() {
        locationProvider.lowAccuracy = PACECloudSDK.shared.config?.allowedLowAccuracy ?? Constants.Configuration.defaultAllowedLowAccuracy
        geoAPIManager.speedThreshold = PACECloudSDK.shared.config?.speedThreshold ?? Constants.Configuration.defaultSpeedThreshold
        geoAPIManager.geoAppsScope = PACECloudSDK.shared.config?.geoAppsScope ?? Constants.Configuration.defaultGeoAppsScope
    }

    func startRetrievingLocation() {
        locationProvider.startFetchingLocation()
    }

    func fetchAppsForOneTimeLocation() {
        oneTimeLocationProvider.requestLocation { [weak self] location in
            guard let location = location else {
                self?.delegate?.didReceiveAppReferences([])
                return
            }
            self?.determineApps(for: location)
        }
    }
}

// MARK: - API requests
extension AppManager {
    private func determineApps(for location: CLLocation) {
        geoAPIManager.apps(for: location) { [weak self] apps in
            guard let apps = apps else {
                // In case the apps couldn't be retrieved
                self?.fetchAppsByLocation(with: location)
                return
            }

            self?.retrieveAppData(for: apps)
        }
    }

    private func fetchAppsByLocation(with location: CLLocation) {
        guard !isLocationFetchRunning else {
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
                    self?.delegate?.passErrorToClient(.couldNotFetchApp)
                    self?.delegate?.didReceiveAppReferences([])
                    AppKitLogger.e("[AppManager] Response doesn't contain any data")
                    return
                }

                self?.retrieveAppData(for: appsResponse)

            case .failure(let error):
                AppKitLogger.e("[AppManager] failed fetching local apps with error \(error)")
                self?.delegate?.passErrorToClient(.couldNotFetchApp)
                self?.delegate?.didReceiveAppReferences([])
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
            guard let manifestUrlString = URLBuilder.buildAppManifestUrl(with: appData.appApiUrl) else {
                AppKitLogger.e("[AppManager] Manifest url string nil")
                return
            }

            var localizationHeader: [String: String]?
            if let currentLanguageCode = AppKitConstants.currentLanguageCode {
                localizationHeader = [HttpHeaderFields.acceptLanguage.rawValue: currentLanguageCode]
            }

            dispatchGroup.enter()
            URLDataRequest.requestJson(with: manifestUrlString, expectedType: AppManifest.self, headers: localizationHeader) { result in
                defer {
                    dispatchGroup.leave()
                }

                switch result {
                case .failure(let error):
                    AppKitLogger.e("[AppManager] Failed fetching app (with gas station id \(appData.gasStationId)) manifest with error: \(String(describing: error))")
                    return

                case .success(let manifest):
                    appData.appManifest = manifest
                    appData.appManifest?.manifestUrl = manifestUrlString

                    guard let decomposedValues = URLDecomposer.decomposeManifestUrl(with: appData.appManifest, appBaseUrl: appData.appApiUrl) else { return }
                    let references = (appData.metadata[AppKit.AppMetadata.references] as? [String])?.first(where: { $0.contains(PRNHelper.gasStationPrefix) })
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
        guard reference.conformsToURN() else {
            delegate?.passErrorToClient(.invalidURNFormat)
            return nil
        }

        return URLBuilder.buildAppStartUrl(with: appUrl, decomposedParams: [.references], references: reference)
    }

    private func retrieveAppData(for geoGasStations: [GeoGasStation]) {
        let appDatas: [AppKit.AppData] = geoGasStations.reduce(into: []) { result, station in
            let metadata: [AppKit.AppMetadata: AnyHashable] = [AppKit.AppMetadata.references: [station.id]]
            let appDatas: [AppKit.AppData] = station.apps.map { app in
                let appData = AppKit.AppData(appID: nil, appUrl: app.url, metadata: metadata)
                return appData
            }
            result.append(contentsOf: appDatas)
        }

        process(appDatas: appDatas, references: geoGasStations.map { $0.id })
    }

    private func retrieveAppData(for locationBasedApps: [PCPOILocationBasedAppWithRefs]) {
        let appDatas: [AppKit.AppData] = locationBasedApps.reduce(into: []) { result, app in
            guard let id = app.id, let gasStationReferences = app.attributes?.references else { return }
            // In case if the identical app contains multiple gas station references

            let appDatas: [AppKit.AppData] = gasStationReferences.map { reference in
                let metadata: [AppKit.AppMetadata: AnyHashable] = [AppKit.AppMetadata.appId: app.id, AppKit.AppMetadata.references: [reference]]
                let appData = AppKit.AppData(appID: id,
                                             appUrl: app.attributes?.pwaUrl,
                                             metadata: metadata)
                return appData
            }
            result.append(contentsOf: appDatas)
        }

        process(appDatas: appDatas, references: locationBasedApps.flatMap { $0.attributes?.references ?? [] })
    }

    private func process(appDatas: [AppKit.AppData], references: [String]) {
        let newGasStationIds = appDatas.map { $0.gasStationId }

        checkDidEscapeForecourtEvent(with: newGasStationIds)
        currentlyDisplayedLocationApps = appDatas
        fetchAppManifest(with: appDatas)
        delegate?.didReceiveAppReferences(references)
    }

    private func checkDidEscapeForecourtEvent(with newApps: [String]) {
        let appsToRemove = currentlyDisplayedLocationApps.filter { !newApps.contains($0.gasStationId) }

        guard !appsToRemove.isEmpty else { return }

        sendEscapedForecourtEvent(to: appsToRemove)
        delegate?.didEscapeForecourt(appsToRemove)
    }

    private func sendEscapedForecourtEvent(to apps: [AppKit.AppData]) {
        apps.forEach {
            NotificationCenter.default.post(name: .appEventOccured, object: AppKit.AppEvent.escapedForecourt(gasStationId: $0.gasStationId))
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
        AppKitLogger.i("[App Manager] Did receive location. Fetching available Apps.")

        determineApps(for: location)
    }

    func didFailWithError(_ error: Error) {
        AppKitLogger.e("[App Manager] Couldn't retrieve location because of \(error)")

        if locationProvider.locationManager.location == nil {
            delegate?.passErrorToClient(.other(error))
        }

        // Reduced Accuracy -> Remove current app drawers
        if let error = error as? CLError, error.code == .deferredAccuracyTooLow {
            sendEscapedForecourtEvent(to: currentlyDisplayedLocationApps)
            delegate?.passErrorToClient(.other(error))
        }
    }
}
