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

    private var traceIdCreatedAt: Date?
    private var currentTraceId: String?

    var currentAccessToken: String?
    var warningsHandler: SDKWarningsHandler?

    public var additionalQueryParams: Set<URLQueryItem>?
    public var redirectScheme: String?
    public var isLoggingEnabled = false
    public weak var loggingDelegate: PACECloudSDKLoggingDelegate?

    public var customURLProtocol: URLProtocol?

    private init() {}

    public func setup(with config: Configuration) {
        self.config = config
        self.apiKey = config.apiKey
        self.authenticationMode = config.authenticationMode
        self.environment = config.environment

        setupCustomURLProtocolIfAvailable()

        self.warningsHandler = SDKWarningsHandler(with: config)
        warningsHandler?.preCheckSetup()

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

// MARK: - Trace ID
extension PACECloudSDK {
    var traceId: String? {
        if abs(traceIdCreatedAt?.timeIntervalSinceNow ?? .greatestFiniteMagnitude) > Constants.Tracing.timeThreshold {
            currentTraceId = String.randomHex(length: 8)
        }
        traceIdCreatedAt = Date()
        return currentTraceId
    }
}

// MARK: - CustomURLProtocol
extension PACECloudSDK {
    var isCustomURLProtocolEnabled: Bool {
        Bundle.main.isCustomURLProtocolKeySet && config?.environment == .development
    }

    private func setupCustomURLProtocolIfAvailable() {
        guard isCustomURLProtocolEnabled, let customURLProtocol = customURLProtocol else { return }
        URLProtocol.registerClass(customURLProtocol.classForCoder)
        URLSession.shared.configuration.setCustomURLProtocolIfAvailable()
    }
}

// MARK: - Configuration
public extension PACECloudSDK {
    struct Configuration {
        let apiKey: String
        let authenticationMode: AuthenticationMode
        let environment: Environment

        let isRedirectSchemeCheckEnabled: Bool

        let domainACL: [String]

        let allowedLowAccuracy: Double
        let speedThreshold: Double
        let geoAppsScope: String

        public init(apiKey: String,
                    authenticationMode: AuthenticationMode = .web,
                    environment: Environment = .production,
                    isRedirectSchemeCheckEnabled: Bool = true,
                    domainACL: [String]? = nil,
                    allowedLowAccuracy: Double? = nil,
                    speedThresholdInKmPerHour: Double? = nil,
                    geoAppsScope: String? = nil) {
            self.apiKey = apiKey
            self.authenticationMode = authenticationMode
            self.environment = environment

            self.isRedirectSchemeCheckEnabled = isRedirectSchemeCheckEnabled

            self.domainACL = domainACL ?? []

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

        public var short: String {
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
