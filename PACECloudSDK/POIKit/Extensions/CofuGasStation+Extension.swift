//
//  CofuGasStation+Extension.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import CoreLocation
import Foundation

public extension Array where Element == POIKit.CofuGasStation {
    var onlineStations: [POIKit.CofuGasStation] {
        filter { $0.cofuStatus == .online }
    }

    var toDictionary: [String: POIKit.CofuGasStation] {
        reduce(into: [:], { $0[$1.id] = $1 })
    }

    func sortedByDistance(from location: CLLocation) -> [POIKit.CofuGasStation] {
        sorted { lhs, rhs -> Bool in
            guard let lhsDistance = lhs.distance(from: location),
                  let rhsDistance = rhs.distance(from: location) else { return false }
            return lhsDistance < rhsDistance
        }
    }
}
