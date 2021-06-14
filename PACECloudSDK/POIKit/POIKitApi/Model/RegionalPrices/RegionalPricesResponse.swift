//
//  RegionalPricesResponse.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation


public extension POIKit {
    struct RegionalPricesResponse: Codable {
        public let data: [RegionalPriceResponse]

        init(_ regionalPrices: PCPOIRegionalPrices) {
            self.data = regionalPrices.data?.compactMap { RegionalPriceResponse($0) } ?? []
        }
    }

    struct RegionalPriceResponse: Codable {
        public let type, id: String
        public let attributes: PriceLevels

        init(_ data: PCPOIRegionalPrices.DataType) {
            self.id = data.id ?? ""
            self.type = data.type?.rawValue ?? ""
            attributes = PriceLevels(data.attributes)
        }
    }

    struct PriceLevels: Codable {
        public let average, lower, upper: Double
        public let currency: String

        init(_ attributes: PCPOIRegionalPrices.DataType.Attributes?) {
            self.average = attributes?.average ?? 0.0
            self.lower = attributes?.lower ?? 0.0
            self.upper = attributes?.upper ?? 0.0
            self.currency = attributes?.currency ?? ""
        }
    }
}
