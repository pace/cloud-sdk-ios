//
//  PriceHistoryResponse.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

public extension POIKit {
    struct PriceHistoryResponse: Codable {
        public let data: PriceHistoryDataResponse
    }

    struct PriceHistoryDataResponse: Codable {
        public let type, id: String?
        public let attributes: PriceHistoryAttributeResponse
    }

    struct PriceHistoryAttributeResponse: Codable {
        public let currency: String
        public let from: String
        public let fuelPrices: [PriceResponse]
        public let productName: String
        public let to: String
    }

    struct PriceResponse: Codable {
        public let at: String
        public let price: Double
    }
}
