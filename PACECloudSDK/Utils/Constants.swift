//
//  Constants.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

struct Constants {
    static let logTag = "[PACECloudSDK]"

    static let isPoiInRangeThreshold: Double = 500

    struct Configuration {
        static let defaultAllowedLowAccuracy: Double = 250
        static let defaultSpeedThreshold: Double = 13
        static let defaultGeoAppsScope: String = "pace-min"
        static let defaultAllowedAppDrawerLocationOffset: Double = 150 // meters
    }

    struct Tracing {
        static let key: String = "uber-trace-id"
        static let timeThreshold: TimeInterval = 60 * 15

        static let spanId: String = "0053444B"
        static let parentSpanId: String = "0"
        static let flags: String = "01"

        static var identifier: String {
            return "\(PACECloudSDK.shared.traceId ?? ""):\(spanId):\(parentSpanId):\(flags)"
        }
    }
}
