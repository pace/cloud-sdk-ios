//
//  Doubles+Angles.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

extension Double {

    var toRadian: Double {
        return self * Double.pi / 180.0
    }

    var toDegrees: Double {
        return self * 180 / Double.pi
    }

    func rotationDifference(to angle: Double, absolute: Bool = true) -> Double {
        let diff1 = (self - angle + 360).truncatingRemainder(dividingBy: 360)
        let diff2 = (angle - self + 360).truncatingRemainder(dividingBy: 360)
        let diff = min(diff1, diff2)
        if absolute {
            return diff
        }

        let from = self == 0 && angle >= 180 ? 360 : self
        let to = angle == 0 && self >= 180 ? 360 : angle
        return from > to ? diff * -1 : diff
    }

}
