//
//  CofuGasStation.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import CoreLocation
import Foundation

public extension POIKit {
    struct CofuGasStation {
        public let id: String
        public let coordinates: GeoAPICoordinate?
        public let polygon: [GeoAPICoordinates]?
        public let properties: [String: Any]
        private(set) public var cofuStatus: CofuStatus?
        private(set) public var fuelingURLs: [String] = []

        public var location: CLLocation? {
            guard let coordinates = coordinates,
                  let lon = coordinates[safe: 0],
                  let lat = coordinates[safe: 1] else { return nil }
            return CLLocation(latitude: lat, longitude: lon)
        }

        private let cofuStatusPropertyKey = "connectedFuelingStatus"
        private let appsPropertyKey = "apps"
        private let fuelingURLPropertyKey = "url"

        init(id: String, coordinates: GeoAPICoordinate?, polygon: [GeoAPICoordinates]?, properties: [String: Any]) {
            self.id = id
            self.coordinates = coordinates
            self.polygon = polygon
            self.properties = properties

            if let statusString = properties[cofuStatusPropertyKey] as? String,
               let status = CofuStatus(rawValue: statusString) {
                self.cofuStatus = status
            }

            if let apps = properties[appsPropertyKey] as? [[String: Any]] {
                fuelingURLs = apps.compactMap { $0[fuelingURLPropertyKey] as? String }
            }
        }

        public func distance(from location: CLLocation) -> CLLocationDistance? {
            if let stationLocation = self.location {
                return stationLocation.distance(from: location)
            } else {
                let edgeDistances: [CLLocationDistance] = polygon?.first?.compactMap { coordinate in
                    guard let lon = coordinate[safe: 0], let lat = coordinate[safe: 1] else { return nil }
                    let polygonEdgeLocation = CLLocation(latitude: lat, longitude: lon)
                    return polygonEdgeLocation.distance(from: location)
                } ?? []
                return edgeDistances.min()
            }
        }
    }
}

public extension POIKit.CofuGasStation {
    enum CofuStatus: String {
        case online, offline
    }

    enum Option {
        case all
        case boundingBox(center: CLLocation, radius: CLLocationDistance)
    }
}
