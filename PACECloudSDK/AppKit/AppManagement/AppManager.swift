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
}

class AppManager {
    weak var delegate: AppManagerDelegate?

    private var locationProvider: AppDrawerLocationProvider

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
                case .invalidSpeed:
                    self?.removeDisplayedAppsIfNeeded(with: location)
                    fallthrough // swiftlint:disable:this fallthrough

                default:
                    completion(nil)
                }

            case .success(let stations):
                let appDatas = self?.retrieveAppData(from: stations, for: location)
                completion(appDatas)
            }
        }
    }

    private func fetchAppManifest(with appDatas: [AppKit.AppData]) {
        let dispatchGroup = DispatchGroup()
        for appData in appDatas {
            guard let appBaseUrlString = appData.appBaseUrl,
                  let manifestUrlString = URLBuilder.buildAppManifestUrl(with: appBaseUrlString) else {
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

    private func retrieveAppData(from cofuGasStations: [POIKit.CofuGasStation], for location: CLLocation) -> [AppKit.AppData] {
        let appDatas: [AppKit.AppData] = cofuGasStations.reduce(into: []) { result, station in
            let metadata: [AppKit.AppMetadata: AnyHashable] = [AppKit.AppMetadata.references: [station.id]]
            let appDatas: [AppKit.AppData] = (station.properties["apps"] as? [[String: Any]] ?? []).map { app in
                let appData = AppKit.AppData(appID: nil, appUrl: app["url"] as? String ?? "", metadata: metadata)
                appData.userDistance = station.location?.distance(from: location)
                appData.userLocationAccuracy = location.verticalAccuracy
                return appData
            }
            result.append(contentsOf: appDatas)
        }

        guard appDatas.count > 1 else { return appDatas }

        for appData in appDatas {
            appData.shouldShowDistance = true
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

    private func removeDisplayedAppsIfNeeded(with newLocation: CLLocation) {
        let allowedLocationOffset = PACECloudSDK.shared.config?.allowedAppDrawerLocationOffset ?? Constants.Configuration.defaultAllowedAppDrawerLocationOffset

        guard let currentlyDisplayedApps = currentlyDisplayedApps,
              !currentlyDisplayedApps.apps.isEmpty,
              currentlyDisplayedApps.location.distance(from: newLocation) > allowedLocationOffset
        else { return }

        let appsToRemove = currentlyDisplayedApps.apps
        removeDisplayedApps(with: appsToRemove)
        delegate?.didEscapeForecourt(appsToRemove)
        self.currentlyDisplayedApps = nil
    }

    private func removeDisplayedApps(with apps: [AppKit.AppData]) {
        apps.forEach {
            NotificationCenter.default.post(name: .appEventOccured, object: AppKit.AppEvent.escapedForecourt(gasStationId: $0.poiId))
        }
    }
}

extension AppManager: AppDrawerLocationProviderDelegate {
    func didReceiveLocation(_ location: CLLocation) {
        AppKitLogger.d("[App Manager] Did receive location. Checking for available apps...")

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
