//
//  GeoElement.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation
import GRDB

extension GeoAPIManager.GeoDatabase {
    struct GeoElement: Codable, Identifiable, FetchableRecord, PersistableRecord {
        let id: String
        let location: Location?
        let polygon: [[Location]]?
        let properties: [String: AnyCodable]?

        init?(from feature: GeoAPIFeature) {
            guard let id = feature.id,
                  let geometry = feature.geometry else { return nil }

            self.id = id

            switch geometry {
            case .point(let point):
                self.location = .init(longitude: point.coordinates[0],
                                      latitude: point.coordinates[1])
                self.polygon = nil

            case .polygon(let polygon):
                self.polygon = polygon.coordinates.compactMap { $0.map { coordinates in
                    return Location(longitude: coordinates[0], latitude: coordinates[1])
                }}
                self.location = nil

            default:
                return nil
            }

            self.properties = feature.properties
        }
    }
}

extension GeoAPIManager.GeoDatabase.GeoElement {
    struct Location: Codable {
        let longitude: Double
        let latitude: Double
    }
}
