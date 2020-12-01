//
//  NavigationRequest.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import CoreLocation

public extension POIKit {
    /** Request a navigation route */
    class NavigationRequest: Equatable {
        /** find the fastest route between coordinates in the supplied order */
        open var coordinates = [CLLocationCoordinate2D]()
        /** search for alternative routes */
        open var alternatives = true
        /** navigation mode */
        open var navigationMode = NavigationMode.car
        var steps = true
        var annotations: [AnnotationType] = [.distance, .duration]
        var geometry = GeometryType.polyline
        var overview = OverviewType.full

        /// :nodoc:
        public init() {}

        func toUrlParams() -> [String: [String]] {
            var annotationsString = annotations.map({ $0.rawValue }).joined(separator: ",")
            if annotationsString.isEmpty {
                annotationsString = "false"
            }

            return [
                "alternatives": ["\(alternatives)"],
                "steps": ["\(steps)"],
                "annotations": [annotationsString],
                "geometries": [geometry.rawValue],
                "overview": [overview.rawValue]
            ]
        }

        /**
         Returns a Boolean value indicating whether two Navigation Requests are equal.

         - parameter lhs: request to compare
         - parameter rhs: Another request to compare
         - returns: if requests are equal
         */
        public static func == (lhs: NavigationRequest, rhs: NavigationRequest) -> Bool {
            return lhs.coordinates == rhs.coordinates &&
                lhs.alternatives == rhs.alternatives &&
                lhs.annotations == rhs.annotations &&
                lhs.navigationMode == rhs.navigationMode &&
                lhs.steps == rhs.steps &&
                lhs.geometry == rhs.geometry &&
                lhs.overview == rhs.overview
        }
    }

    /** mode of the navigation */
    enum NavigationMode: String {
        /** navigation by car */
        case car

        /** navigation by foot */
        case foot

        /** navigation by bike */
        case bike
    }
}

enum AnnotationType: String {
    /** OSM node ID for each coordinate along the route, excluding the first/last user-supplied coordinates */
    case nodes
    /** distance, in metres, between each pair of coordinates */
    case distance
    /** duration between each pair of coordinates, in seconds. Does not include the duration of any turns. */
    case duration
    /** index of the datasource for the speed between each pair of coordinates */
    case datasources
    /** weights between each pair of coordinates */
    case weight
    /** calculation of distance / duration rounded to one decimal place */
    case speed
}

enum GeometryType: String {
    /** polyline with precision 5 in [latitude,longitude] encoding */
    case polyline

    /** polyline with precision 6 in [latitude,longitude] encoding */
    case polyline6

    /** GeoJSON LineString */
    case geojson
}

enum OverviewType: String {
    /** geometry is simplified according to the highest zoom level it can still be displayed on full */
    case simplified = "simplified"

    /** geometry is not simplified */
    case full = "full"

    /** geometry is not added */
    case none = "false"
}
