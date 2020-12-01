//
//  Route.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import CoreLocation

public extension POIKit {
    /** Represents a route through (potentially multiple) waypoints. */
    class Route: NSObject, Decodable {
        /** distance traveled by the route, in meters */
        internal(set) open var distanceInM: Double = 0.0
        /** estimated travel time, in number of seconds */
        internal(set) open var durationInSeconds: Double = 0.0
        /** whole geometry of the route value depending on overview parameter, format depending on the geometries parameter */
        internal(set) open var geometry: POIKit.Polyline?
        /** navigation mode of the route */
        internal(set) open var navigationMode = NavigationMode.car

        /** coordinate representation of the route */
        open var coordinates: [CLLocationCoordinate2D] {
            return geometry?.coordinates ?? [CLLocationCoordinate2D]()
        }

        private enum CodingKeys: String, CodingKey {
            case distance
            case duration
            case geometry
            case legs
        }

        /// :nodoc:
        public required init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            self.distanceInM = (try? values.decode(Double.self, forKey: .distance)) ?? 0.0
            self.durationInSeconds = (try? values.decode(Double.self, forKey: .duration)) ?? 0.0
            if let geometry = try? values.decode(String.self, forKey: .geometry) {
                self.geometry = POIKit.Polyline(encodedPolyline: geometry)
            }
            super.init()
        }

        /// :nodoc:
        public override init() {
            super.init()
        }
    }
}
