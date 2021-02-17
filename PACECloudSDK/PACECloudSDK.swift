//
//  PACECloudSDK.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

public class PACECloudSDK {
    public static let shared = PACECloudSDK()

    private(set) var config: Configuration?
    private(set) var environment: Environment = .production
    private(set) var authenticationMode: AuthenticationMode = .web
    private(set) var userAgentExtensions: [String] = []

    private(set) var apiKey: String?
    var currentAccessToken: String?

    public var additionalQueryParams: Set<URLQueryItem>?

    public var isLoggingEnabled = false
    public weak var loggingDelegate: PACECloudSDKLoggingDelegate?

    public var redirectScheme: String?

    public func setup(with config: Configuration) {
        self.config = config
        self.apiKey = config.apiKey
        self.authenticationMode = config.authenticationMode
        self.environment = config.environment

        AppKit.shared.setup()

        setupAPI()
    }

    public func extendUserAgent(with extensions: [String]) {
        userAgentExtensions = extensions
    }

    public func resetAccessToken() {
        currentAccessToken = nil
    }
}

public extension PACECloudSDK {
    struct Configuration {
        let apiKey: String
        let authenticationMode: AuthenticationMode
        let environment: Environment

        let allowedLowAccuracy: Double
        let speedThreshold: Double
        let geoAppsScope: String

        public init(apiKey: String,
                    authenticationMode: AuthenticationMode = .web,
                    environment: Environment = .production,
                    allowedLowAccuracy: Double? = nil,
                    speedThresholdInKmPerHour: Double? = nil,
                    geoAppsScope: String? = nil) {
            self.apiKey = apiKey
            self.authenticationMode = authenticationMode
            self.environment = environment

            self.allowedLowAccuracy = allowedLowAccuracy ?? Constants.Configuration.defaultAllowedLowAccuracy

            if let speedThresholdInKmPerHour = speedThresholdInKmPerHour {
                self.speedThreshold = (speedThresholdInKmPerHour / 3.6).round(1)
            } else {
                self.speedThreshold = Constants.Configuration.defaultSpeedThreshold
            }

            self.geoAppsScope = geoAppsScope ?? Constants.Configuration.defaultGeoAppsScope
        }
    }

    enum Environment: String {
        case development
        case sandbox
        case stage
        case production

        var short: String {
            switch self {
            case .development:
                return "dev"

            case .sandbox:
                return "sandbox"

            case .stage:
                return "stage"

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
