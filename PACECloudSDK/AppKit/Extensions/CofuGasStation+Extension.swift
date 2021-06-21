//
//  CofuGasStation+Extension.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import CoreLocation
import Foundation

public extension Array where Element == AppKit.CofuGasStation {
    var onlineStations: [AppKit.CofuGasStation] {
        filter { $0.cofuStatus == .online }
    }

    func sortedByDistance(from location: CLLocation) -> [AppKit.CofuGasStation] {
        sorted { lhs, rhs -> Bool in
            guard let lhsDistance = lhs.distance(from: location),
                  let rhsDistance = rhs.distance(from: location) else { return false }
            return lhsDistance < rhsDistance
        }
    }
}
