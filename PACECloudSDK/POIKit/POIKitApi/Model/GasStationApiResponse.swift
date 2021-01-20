//
//  GasStationApiResponse.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation


public extension POIKit {
    struct GasStationResponse: Codable {
        var id: String
        public var gasStation: PCPOIGasStation
        public var prices: [PCPOIFuelPrice]
        public var wasMoved: Bool?
    }
}
