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
