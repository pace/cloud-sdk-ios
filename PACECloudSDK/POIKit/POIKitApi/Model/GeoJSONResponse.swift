//
//  GeoJSONResponse.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

public extension POIKit {
    struct GeoJSONResponse: Codable {
        public let type: String?
        public let features: [GeoJSONFeatureResponse]?
    }

    struct GeoJSONFeatureResponse: Codable {
        public let id: String?
        public let type: String?
        public let geometry: GeoJSONGeometry?
        public let properties: GeoJSONPropertyResponse?
    }

    struct GeoJSONPropertyResponse: Codable {
        public let address: GeoJSONAddressResponse?
        public let brand: String?
        public let dkvStationID: String?
        public let stationName: String?
        public let type: String?
    }

    struct GeoJSONAddressResponse: Codable {
        public let city: String?
        public let countryCode: String?
        public let houseNo: String?
        public let postalCode: String?
        public let street: String?
    }
}
