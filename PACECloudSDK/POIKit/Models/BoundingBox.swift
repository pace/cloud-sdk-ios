//
//  BoundingBox.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import CoreLocation
import MapKit

public extension POIKit {
    /// Bounding Box that defines an area
    struct BoundingBox: Equatable {
        /// top right point
        public let point1: CLLocationCoordinate2D
        /// bottom left point
        public let point2: CLLocationCoordinate2D
        /// center point
        public let center: CLLocationCoordinate2D

        public var diameter: CLLocationDistance {
            return point1.distance(from: point2)
        }

        private static let precisionFormat = "%.5f"

        /**
         Creates a bounding box by calculating the edge points for the given center coordinate and radius

         - parameter center: center coordinate
         - parameter radius: radius in meters
         */
        public init(center: CLLocationCoordinate2D, radius: Double) {
            let topRightPoint = center.move(by: radius / 1000, atBearingDegrees: 45)
            let bottomLeftPoint = center.move(by: radius / 1000, atBearingDegrees: 180 + 45)
            self.init(point1: topRightPoint, point2: bottomLeftPoint, center: center)
        }

        /// :nodoc:
        public init(point1: CLLocationCoordinate2D, point2: CLLocationCoordinate2D, center: CLLocationCoordinate2D) {
            self.point1 = point1
            self.point2 = point2
            self.center = center
        }

        public func contains(coord: CLLocationCoordinate2D) -> Bool {
            let minLat = min(point1.latitude, point2.latitude)
            let maxLat = max(point1.latitude, point2.latitude)
            let minLon = min(point1.longitude, point2.longitude)
            let maxLon = max(point1.longitude, point2.longitude)

            return minLat ... maxLat ~= coord.latitude && minLon ... maxLon ~= coord.longitude
        }

        public static func == (lhs: BoundingBox, rhs: BoundingBox) -> Bool {
            let precision = BoundingBox.precisionFormat
            return String(format: precision, lhs.point1.latitude) == String(format: precision, rhs.point1.latitude) &&
                String(format: precision, lhs.point1.longitude) == String(format: precision, rhs.point1.longitude) &&
                String(format: precision, lhs.point2.latitude) == String(format: precision, rhs.point2.latitude) &&
                String(format: precision, lhs.point2.longitude) == String(format: precision, rhs.point2.longitude)
        }
    }
}
