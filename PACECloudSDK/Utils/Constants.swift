//
//  Constants.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

struct Constants {
    static let logTag = "[PACECloudSDK]"

    struct Configuration {
        static let defaultAllowedLowAccuracy: Double = 200
        static let defaultSpeedThreshold: Double = 13
        static let defaultGeoAppsScope: String = "pace"
    }
}
