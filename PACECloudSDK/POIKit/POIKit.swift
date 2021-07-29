//
//  PACECloudSDK.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import CoreLocation
import Foundation

public class POIKit {
    static var shared: POIKit {
        PACECloudSDK.shared.warningsHandler?.logSDKWarningsIfNeeded()
        return sharedInstance
    }

    private static var sharedInstance: POIKit = POIKit()

    private var geoAPIManager: GeoAPIManager
    private lazy var oneTimeLocationProvider: OneTimeLocationProvider = .init()

    private init() {
        geoAPIManager = GeoAPIManager()
    }

    static func setup() {
        shared.geoAPIManager.speedThreshold = PACECloudSDK.shared.config?.speedThreshold ?? Constants.Configuration.defaultSpeedThreshold
        shared.oneTimeLocationProvider.lowAccuracy = PACECloudSDK.shared.config?.allowedLowAccuracy ?? Constants.Configuration.defaultAllowedLowAccuracy
        shared.geoAPIManager.geoAppsScope = PACECloudSDK.shared.config?.geoAppsScope ?? Constants.Configuration.defaultGeoAppsScope
    }
}

extension POIKit {
    func locationBasedCofuStations(for location: CLLocation, completion: @escaping (Result<[CofuGasStation], GeoApiManagerError>) -> Void) {
        geoAPIManager.locationBasedCofuStations(for: location, result: completion)
    }

    func requestCofuGasStations(option: CofuGasStation.Option = .all, completion: @escaping ([CofuGasStation]?) -> Void) {
        geoAPIManager.cofuGasStations(option: option) { result in
            guard case let .success(stations) = result else {
                completion(nil)
                return
            }
            completion(stations)
        }
    }

    func isPoiInRange(id: String, completion: @escaping ((Bool) -> Void)) {
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
}
