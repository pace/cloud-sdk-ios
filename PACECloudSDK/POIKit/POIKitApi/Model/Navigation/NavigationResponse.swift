//
//  NavigationResponse.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import CoreLocation

public extension POIKit {
    /** response containing navigation routes */
    class NavigationResponse: Decodable {
        /** array of waypoint objects representing all waypoints in order */
        open var waypoints = [Waypoint]()
        /** array of route objects, ordered by descending recommendation rank */
        open var routes = [Route]()
    }
}
