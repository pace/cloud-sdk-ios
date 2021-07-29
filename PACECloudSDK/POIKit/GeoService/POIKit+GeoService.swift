//
//  POIKit+GeoService.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import CoreLocation
import Foundation

extension POIKit {
    static func locationBasedCofuStations(for location: CLLocation, completion: @escaping (Result<[CofuGasStation], GeoApiManagerError>) -> Void) {
        shared.locationBasedCofuStations(for: location, completion: completion)
    }
}

public extension POIKit {
    static func requestCofuGasStations(option: CofuGasStation.Option = .all, completion: @escaping ([CofuGasStation]?) -> Void) {
        shared.requestCofuGasStations(option: option, completion: completion)
    }

    // MARK: - POI proximity check
    static func isPoiInRange(id: String, completion: @escaping ((Bool) -> Void)) {
        shared.isPoiInRange(id: id, completion: completion)
    }
}
