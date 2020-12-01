//
//  Waypoint.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import CoreLocation

public extension POIKit {
    /** Object used to describe waypoint on a route */
    class Waypoint: NSObject, Decodable {
        /** location of the waypoint */
        open var location = CLLocationCoordinate2D()
        /** Name of the street the coordinate snapped to */
        open var name = ""
        /**
         Unique internal identifier of the segment (ephemeral, not constant over data updates)
         This can be used on subsequent request to significantly speed up the query and to connect multiple services.
         E.g. you can use the hint value obtained by the nearest query as hint values for route inputs.
         */
        open var hint: String?

        private enum CodingKeys: String, CodingKey {
            case location
            case name
            case hint
        }

        /// :nodoc:
        public required init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            self.name = (try? values.decode(String.self, forKey: .name)) ?? ""
            if let locations = try? values.decode([Double].self, forKey: .location),
                locations.count == 2 {
                self.location = CLLocationCoordinate2D(latitude: locations[1], longitude: locations[0])
            }
            self.hint = try? values.decode(String.self, forKey: .hint)
        }

        /// :nodoc:
        public override init() {
            super.init()
        }
    }
}
