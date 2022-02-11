//
//  POIKitApiProtocol.swift
//  PACECloudSlimSDK
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

    private var currentEnvironment: PACECloudSDK.Environment

    private init() {
        geoAPIManager = GeoAPIManager()
        currentEnvironment = PACECloudSDK.shared.environment
    }
}

extension POIKit {
    static func locationBasedCofuStations(for location: CLLocation, completion: @escaping (Result<[CofuGasStation], GeoApiManagerError>) -> Void) {
        shared.locationBasedCofuStations(for: location, completion: completion)
    }

    func locationBasedCofuStations(for location: CLLocation, completion: @escaping (Result<[CofuGasStation], GeoApiManagerError>) -> Void) {
        geoAPIManager.locationBasedCofuStations(for: location, result: completion)
    }
}

protocol POIKitAPIProtocol {}
