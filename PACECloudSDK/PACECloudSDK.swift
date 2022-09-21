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
    private(set) var authenticationMode: AuthenticationMode = .native
    private(set) var userAgentExtensions: [String] = []
    private(set) var apiKey: String?

    private var traceIdCreatedAt: Date?
    private var currentTraceId: String?

    var warningsHandler: SDKWarningsHandler?

    public var additionalQueryParams: Set<URLQueryItem>? {
        didSet {
            guard let params = additionalQueryParams else { return }
            IDKit.handleAdditionalQueryParams(params)
        }
    }

    public var redirectScheme: String?
    public var isLoggingEnabled = false {
        didSet {
            if isLoggingEnabled {
                SDKLogger.optIn()
            } else {
                SDKLogger.optOut()
            }
        }
    }

    public var customURLProtocol: URLProtocol?
    public weak var delegate: PACECloudSDKDelegate?

    /// Holds the localizations of the strings used in the SDK.
    ///
    /// To customize localizations either subclass `PACECloudSDK.Localizable` or
    /// implement the `PACELocalizable` protocol and set this property accordingly.
    public var localizable: PACELocalizable = PACECloudSDK.Localizable()

    private init() {}

    public func setup(with config: Configuration) {
        self.config = config
        self.apiKey = config.apiKey
        self.authenticationMode = config.authenticationMode
        self.environment = config.environment
        self.isLoggingEnabled = config.loggingEnabled

        setupCustomURLProtocolIfAvailable()

        self.warningsHandler = SDKWarningsHandler(with: config)
        warningsHandler?.preCheckSetup()

        SDKUserDefaults.migrate()
        SDKKeychain.migrate()

        setupKits(with: config)
        setupAPI()
    }

    /**
     Extends the user agent by the specified values.
     - parameter extensions: The values the user agent should be extended with.
     */
    public func extendUserAgent(with extensions: [String]) {
        userAgentExtensions = extensions
    }

    /**
     Handles the specified redirect URL within an `AppViewController`.
     - parameter url: The redirect URL.
     */
    @discardableResult
    public func application(open url: Foundation.URL) -> Bool {
        switch url.host {
        case Constants.applicationURLRedirectHost:
            AppKit.handleRedirectURL(with: url)
            return true

        default:
            return false
        }
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
