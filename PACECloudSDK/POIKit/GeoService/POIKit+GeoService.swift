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
     Requests connected fueling gas stations for the specified option.

     The response does also include connected fueling stations that are currently **offline**.
     You may use the `onlineStations` property on the response array to filter the stations by their online status.

     ```swift
     POIKit.requestCofuGasStations(option: .all) { cofuStations in
        let onlineStations = cofuStations?.onlineStations
     }
     ```

     If you wish to retrieve connected fueling stations that contain more detailed information use
     `requestCofuGasStations(center: CLLocation, radius: CLLocationDistance,`
     `includesOnlineOnly: Bool = true, completion: @escaping (Result<[POIKit.GasStation], POIKitAPIError>) -> Void)`
     instead.

     - parameter option: The option that defines which connected fueling gas stations will be contained in the response.
     - parameter completion: The block to be called when the response is available either containing a list of connected fueling gas stations or `nil` if the retrieval failed.
     */
    static func requestCofuGasStations(option: CofuGasStation.Option = .all, completion: @escaping ([CofuGasStation]?) -> Void) {
        shared.requestCofuGasStations(option: option, completion: completion)
    }

    /**
     Requests connected fueling gas stations for the specified area with detailed information.

     If you only need a list of connected fueling gas stations e.g. for their ids or their location, please use
     `requestCofuGasStations(option: CofuGasStation.Option = .all, completion: @escaping ([CofuGasStation]?) -> Void)`
     instead.

     - parameter center: The center of the area you are requesting.
     - parameter radius: The radius for the desired area.
     - parameter includesOnlineOnly: If `true` only gas stations that are currently online will be included in the response. Defaults to `true`.
     - parameter completion: The block to be called when the response is available
     either containing a list of online connected fueling gas stations with detailed information or an `error`.
     */
    static func requestCofuGasStations(center: CLLocation,
                                       radius: CLLocationDistance,
                                       includesOnlineOnly: Bool = true,
                                       completion: @escaping (Result<[POIKit.GasStation], POIKitAPIError>) -> Void) {
        shared.requestCofuGasStations(center: center,
                                      radius: radius,
                                      includesOnlineOnly: includesOnlineOnly,
                                      completion: completion)
    }

    /**
     Checks if the connected fueling gas station with the specified id is in range of the user's current location.
     - parameter id: The id of the gas station.
     - parameter location: The location to be checked. Defaults to `nil`. If `location` is not specified the SDK will request the current location itself.
     - parameter completion: The block to be called when the check has been completed containing the result.
     */
    static func isPoiInRange(id: String, at location: CLLocation? = nil, completion: @escaping ((Bool) -> Void)) {
        shared.isPoiInRange(id: id, at: location, completion: completion)
    }
}
