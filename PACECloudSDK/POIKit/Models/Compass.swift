//
//  Compass.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

enum Compass {
    case north
    case east
    case south
    case west

    init(bearing: Int) {
        switch (bearing + 360) % 360 {
        case 45...135:
            self = .east

        case 136...225:
            self = .south

        case 226...315:
            self = .west

        default:
            self = .north
        }
    }
}
