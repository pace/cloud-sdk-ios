//
//  GeometryCommand.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//
// Documentation see https://github.com/mapbox/vector-tile-spec/tree/master/2.1 chapter 4.3

import CoreLocation

public extension POIKit {
    class GeometryCommand {
        public var type: CommandType
        public var location: Location

        public init(type: CommandType, coordinate: CLLocationCoordinate2D) {
            self.type = type
            self.location = Location(coordinate: coordinate)
        }
    }

    enum CommandType: Int {
        case undefined = 0
        case moveTo = 1
        case lineTo = 2
        case closePath = 3

        public var paramCount: Int {
            switch self {
            case .moveTo, .lineTo:
                return 2

            case .closePath:
                return 0

            default:
                fatalError()
            }
        }
    }
}
