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
    /**
     Request connected fueling gas stations for the specified option.
     - parameter option: The option that defines which connected fueling gas stations will be contained in the response.
     - parameter completion: The block to be called when the response is available either containing a list of connected fueling gas stations or `nil` if the retrieval failed.
     */
    static func requestCofuGasStations(option: CofuGasStation.Option = .all, completion: @escaping ([CofuGasStation]?) -> Void) {
        shared.requestCofuGasStations(option: option, completion: completion)
    }

    /**
     Checks if the gas station with the specified id is in the range of the user's current location.
     - parameter id: The id of the gas station.
     - parameter completion: The block to be called when the check has been completed containing the result.
     */
    static func isPoiInRange(id: String, completion: @escaping ((Bool) -> Void)) {
        shared.isPoiInRange(id: id, completion: completion)
    }
}
