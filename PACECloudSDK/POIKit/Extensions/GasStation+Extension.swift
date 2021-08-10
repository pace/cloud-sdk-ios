//
//  GasStation+Extension.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import CoreLocation
import Foundation

public extension Array where Element == POIKit.GasStation {
    func sortedByDistance(from location: CLLocation) -> [POIKit.GasStation] {
        sorted { lhs, rhs -> Bool in
            guard let lhsPoiLocation = lhs.geometry.first?.location,
                  let rhsPoiLocation = rhs.geometry.first?.location else { return false }

            let lhsDistance = lhsPoiLocation.coordinate.distance(from: location.coordinate)
            let rhsDistance = rhsPoiLocation.coordinate.distance(from: location.coordinate)

            return lhsDistance < rhsDistance
        }
    }
}
