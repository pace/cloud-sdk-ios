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

    static let applicationURLRedirectHost = "redirect"

    static let fallbackRedirectScheme = "cloudsdk"

    static let paymentMethodVendorIconsCMSPrefix = "cms/images"
    static let cdnPayPath = "/pay"
    static let cdnPaymentMethodVendorsPath = "/payment-method-vendors"

    struct Configuration {
        static let defaultAllowedLowAccuracy: Double = 250
        static let defaultSpeedThreshold: Double = 13
        static let defaultAllowedAppDrawerLocationOffset: Double = 150 // meters
        static let defaultDomainACL: [String] = ["pace.cloud", "fuel.site"]
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

    struct CofuGasStationProperty {
        static let paymentMethodKindsKey = "paymentMethodKinds"
    }

    static let userDefaultsMigrationVersionKey = "pacecloudsdk_user_defaults_migration_version"
    static let keychainMigrationVersionKey = "pacecloudsdk_keychain_migration_version"

    static let userDefaultsSuiteNameSuffix = "pacecloudsdk_user_defaults_suite"
}
