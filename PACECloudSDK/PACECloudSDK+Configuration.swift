//
//  PACECloudSDK+Configuration.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

public extension PACECloudSDK {
    struct Configuration {
        /// Is mandatory to be set. Your API key provided by PACE.
        let apiKey: String

        /// The default authentication mode is `.native`. If you're not using native authentication set this value to `.web`.
        let authenticationMode: AuthenticationMode

        /// Default is `.production`. During development this should be set to `.sandbox`.
        let environment: Environment

        /// Set if you want to use your own OID Configuration.
        let customOIDConfiguration: IDKit.OIDConfiguration?

        /// Determines whether a `SFSafariViewController/SFAuthenticationSession` or a `WKWebView` is used to handle the OID authorization flow.
        /// Defaults to `.external` that uses the former.
        let oidUserAgentType: IDKit.UserAgentType

        /// By Default this is `true`. If you don't use redirects in your client and want to suppress the corresponding log messages,  set this to `false`.
        let isRedirectSchemeCheckEnabled: Bool

        /// List of domains which are allowed to access secured data.
        let domainACL: [String]

        /// Accuracy in meters the user location has to have at least to check for Connected Fueling Stations around them.
        let allowedLowAccuracy: Double

        /// The speed in km/h users have to move to stop checking for Connected Fueling Stations around them.
        let speedThreshold: Double

        /// Can be specified if special Connected Fueling requirements are needed.
        let geoAppsScope: String

        /// Maximum distance of Cofu station to user in meters to still be shown.
        let allowedAppDrawerLocationOffset: Double

        /// Set to `true` if you want to make use of the Logger provided by `PACECloudSDK`.
        let loggingEnabled: Bool

        public init(apiKey: String,
                    authenticationMode: AuthenticationMode = .native,
                    environment: Environment = .production,
                    customOIDConfiguration: IDKit.OIDConfiguration? = nil,
                    oidUserAgentType: IDKit.UserAgentType = .external,
                    isRedirectSchemeCheckEnabled: Bool = true,
                    domainACL: [String]? = nil,
                    allowedLowAccuracy: Double? = nil,
                    speedThresholdInKmPerHour: Double? = nil,
                    geoAppsScope: String? = nil,
                    allowedAppDrawerLocationOffset: Double? = nil,
                    enableLogging: Bool = false) {
            self.apiKey = apiKey
            self.authenticationMode = authenticationMode
            self.environment = environment
            self.customOIDConfiguration = customOIDConfiguration
            self.oidUserAgentType = oidUserAgentType

            self.isRedirectSchemeCheckEnabled = isRedirectSchemeCheckEnabled

            self.domainACL = domainACL ?? Constants.Configuration.defaultDomainACL

            self.allowedLowAccuracy = allowedLowAccuracy ?? Constants.Configuration.defaultAllowedLowAccuracy

            if let speedThresholdInKmPerHour = speedThresholdInKmPerHour {
                self.speedThreshold = (speedThresholdInKmPerHour / 3.6).round(1)
            } else {
                self.speedThreshold = Constants.Configuration.defaultSpeedThreshold
            }

            self.geoAppsScope = geoAppsScope ?? Constants.Configuration.defaultGeoAppsScope
            self.allowedAppDrawerLocationOffset = allowedAppDrawerLocationOffset ?? Constants.Configuration.defaultAllowedAppDrawerLocationOffset
            self.loggingEnabled = enableLogging
        }
    }

    enum Environment: String {
        case development
        case sandbox
        case production

        public var short: String {
            switch self {
            case .development:
                return "dev"

            case .sandbox:
                return "sandbox"

            case .production:
                return "prod"
            }
        }
    }

    enum AuthenticationMode: String {
        case native
        case web
    }
}
