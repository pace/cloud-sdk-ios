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

    private var locationProvider: LocationProvider
    private var isLocationFetchRunning = false
    private var isGeneralFetchRunning = false
    private var currentlyDisplayedLocationApps: [AppKit.AppData] = []

    init() {
        locationProvider = LocationProvider()
        locationProvider.delegate = self
    }

    func setAllowedLocationAccuracy(_ value: Double) {
        locationProvider.lowAccuracy = value
    }

    func startRetrievingLocation() {
        locationProvider.startFetchingLocation()
    }

    private func fetchAppByLocation(with location: CLLocation) {
        guard !isLocationFetchRunning else {
            delegate?.passErrorToClient(.fetchAlreadyRunning)
            return
        }

        let lat: Float = Float(location.coordinate.latitude)
        let lon: Float = Float(location.coordinate.longitude)

        AppKitLogger.i("[AppManager] Fetching Apps for location: \(lat), \(lon)")

        isLocationFetchRunning = true

        let apiRequest = POIAPI.Apps.CheckForPaceApp.Request(filterlatitude: lat, filterlongitude: lon)
        POIKitAPI.shared.request.client.makeRequest(apiRequest) { [weak self] apiResult in
            defer {
                self?.isLocationFetchRunning = false
                self?.locationProvider.locationManager.stopUpdatingLocation()
            }

            switch apiResult.result {
            case .success(let response):
                guard let apps = response.success?.data else {
                    self?.delegate?.passErrorToClient(.couldNotFetchApp)
                    self?.delegate?.didReceiveAppReferences([])
                    AppKitLogger.e("[AppManager] Response doesn't contain any data")
                    return
                }

                var appDatas: [AppKit.AppData] = []

                for app in apps {
                    guard let id = app.id, let attributes = app.attributes, let gasStationReferences = attributes.references else {
                        continue
                    }

                    // In case if the identical app contains multiple gas station references
                    gasStationReferences.forEach {
                        let metadata: [AppMetadata: AnyHashable] = [AppMetadata.appId: app.id, AppMetadata.references: [$0]]
                        let appData = AppKit.AppData(appID: id,
                                              appUrl: attributes.pwaUrl,
                                              metadata: metadata)

                        appDatas.append(appData)
                    }
                }

                let newAppIds = appDatas.map { $0.appID }

                self?.checkDidEscapeForecourtEvent(with: newAppIds)
                self?.currentlyDisplayedLocationApps = appDatas
                self?.fetchAppManifest(with: appDatas)
                self?.delegate?.didReceiveAppReferences(apps.flatMap { $0.attributes?.references ?? [] })

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
        POIKitAPI.shared.request.client.makeRequest(apiRequest) { [weak self] apiResult in
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

                    let metadata: [AppMetadata: AnyHashable] = [AppMetadata.appId: app.id]

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
                    AppKitLogger.e("[AppManager] Failed fetching app (with id \(appData.appID)) manifest with error: \(String(describing: error))")
                    return

                case .success(let manifest):
                    appData.appManifest = manifest
                    appData.appManifest?.manifestUrl = manifestUrlString

                    guard let decomposedValues = URLDecomposer.decomposeManifestUrl(with: appData.appManifest, appBaseUrl: appData.appApiUrl) else { return }
                    let references = (appData.metadata[AppMetadata.references] as? [String])?.first(where: { $0.contains(PRNHelper.gasStationPrefix) })
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

    private func checkDidEscapeForecourtEvent(with newApps: [String]) {
        let appsToRemove = currentlyDisplayedLocationApps.filter { !newApps.contains($0.appID) }

        guard !appsToRemove.isEmpty else { return }

        sendEscapedForecourtEvent(to: appsToRemove)
        delegate?.didEscapeForecourt(appsToRemove)
    }

    private func sendEscapedForecourtEvent(to apps: [AppKit.AppData]) {
        apps.forEach {
            NotificationCenter.default.post(name: .appEventOccured, object: AppKit.AppEvent.escapedForecourt(uuid: $0.appID))
        }
    }
}

extension AppManager: LocationProviderDelegate {
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

        fetchAppByLocation(with: location)
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
