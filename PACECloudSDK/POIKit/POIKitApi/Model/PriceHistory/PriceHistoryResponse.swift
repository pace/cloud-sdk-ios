//
//  PriceHistoryResponse.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

public typealias AnyPriceHistoryResponse = Decodable

// MARK: - GasStation Id / Country Code
public extension POIKit {
    struct PriceHistoryResponse: AnyPriceHistoryResponse {
        public let fuelType: String
        public let prices: [PriceHistoryPriceResponse]

        private enum CodingKeys: String, CodingKey {
            case fuelType = "fuel_type"
            case prices
        }
    }
}

public extension POIKit.PriceHistoryResponse {
    struct PriceHistoryPriceResponse: AnyPriceHistoryResponse {
        public let currency: String
        public let data: [PriceHistoryDataResponse]
    }
}

public extension POIKit.PriceHistoryResponse.PriceHistoryPriceResponse {
    struct PriceHistoryDataResponse: AnyPriceHistoryResponse {
        public let time: String
        public let price: Double
    }
}

// MARK: - GasStation Id / Country Code + FuelType
public extension POIKit {
    struct PriceHistoryFuelTypeResponse: AnyPriceHistoryResponse {
        public let time: String
        public let price: Double
        public let currency: String
    }
}
