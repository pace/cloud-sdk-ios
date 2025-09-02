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

        public let padding: Double

        public var diameter: CLLocationDistance {
            return point1.distance(from: point2)
        }

        public var minLat: CLLocationDistance {
            min(point1.latitude, point2.latitude)
        }

        public var maxLat: CLLocationDistance {
            max(point1.latitude, point2.latitude)
        }

        public var minLon: CLLocationDistance {
            min(point1.longitude, point2.longitude)
        }

        public var maxLon: CLLocationDistance {
            max(point1.longitude, point2.longitude)
        }

        private static let precisionFormat = "%.5f"

        /**
         Creates a bounding box by calculating the edge points for the given center coordinate and radius

         - parameter center: center coordinate
         - parameter radius: radius in meters
         */
        public init(center: CLLocationCoordinate2D, radius: Double, padding: Double = 0) {
            let topRightPoint = center.move(by: radius / 1000, atBearingDegrees: 45)
            let bottomLeftPoint = center.move(by: radius / 1000, atBearingDegrees: 180 + 45)
            self.init(point1: topRightPoint, point2: bottomLeftPoint, center: center, padding: padding)
        }

        /// :nodoc:
        public init(point1: CLLocationCoordinate2D, point2: CLLocationCoordinate2D, center: CLLocationCoordinate2D, padding: Double = 0) {
            self.point1 = point1
            self.point2 = point2
            self.center = center
            self.padding = padding
        }

        public func contains(coord: CLLocationCoordinate2D) -> Bool {
            return minLat ... maxLat ~= coord.latitude && minLon ... maxLon ~= coord.longitude
        }

        public static func incrementalPadding(maxIncrements: Int,
                                              currentIncrement: Int,
                                              maxPadding: Double = 0.85,
                                              minPading: Double = 0) -> Double {
            let paddingDifference = maxPadding - minPading
            let increments = Double(maxIncrements)
            let factor = increments - Double(currentIncrement)
            let relativePadding = (paddingDifference / increments) * factor

            let padding = relativePadding + (maxPadding - paddingDifference)

            if padding >= maxPadding {
                return maxPadding
            } else if padding <= minPading {
                return minPading
            }

            return padding
        }

        public static func == (lhs: BoundingBox, rhs: BoundingBox) -> Bool {
            let precision = BoundingBox.precisionFormat
            return String(format: precision, lhs.point1.latitude) == String(format: precision, rhs.point1.latitude) &&
                String(format: precision, lhs.point1.longitude) == String(format: precision, rhs.point1.longitude) &&
                String(format: precision, lhs.point2.latitude) == String(format: precision, rhs.point2.latitude) &&
                String(format: precision, lhs.point2.longitude) == String(format: precision, rhs.point2.longitude) &&
                lhs.padding == rhs.padding
        }
    }
}
