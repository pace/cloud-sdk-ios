//
//  CoordinateLocation.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

enum CoordinateLocation {
    case before, between, after

    init(modifier: Float) {
        if modifier < 0 {
            self = .before
        } else if modifier > 1 {
            self = .after
        } else {
            self = .between
        }
    }
}
