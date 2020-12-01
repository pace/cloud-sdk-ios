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
        public var gasStation: PCGasStation
        public var prices: [PCFuelPrice]
        public var wasMoved: Bool?
    }
}
