//
//  GeoElement.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation
internal import GRDB

extension GeoAPIManager.GeoDatabase {
    struct GeoElement: Codable, Identifiable, FetchableRecord, PersistableRecord {
        private(set) var id: Int? // Database primary key - nil before insert

        let poiId: String
        let properties: [String: AnyCodable]?
        let longitude: Double
        let latitude: Double

        init(poiId: String, longitude: Double, latitude: Double, properties: [String: AnyCodable]?) {
            self.poiId = poiId
            self.longitude = longitude
            self.latitude = latitude
            self.properties = properties
        }
    }
}
