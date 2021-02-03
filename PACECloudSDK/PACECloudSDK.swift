//
//  PACECloudSDK.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

public class PACECloudSDK {
    public static let shared = PACECloudSDK()

    private(set) var environment: Environment = .production
    private(set) var authenticationMode: AuthenticationMode = .web
    private(set) var configValues: [ConfigValue: Any]?
    private(set) var userAgentExtensions: [String] = []

    private(set) var apiKey: String?
    private(set) var clientId: String?
    var currentAccessToken: String?

    public var additionalQueryParams: Set<URLQueryItem>?

    private init() {
        URLSession.shared.configuration.protocolClasses = [CustomURLProtocol.self]
    }

    public func setup(with config: Configuration) {
        self.clientId = config.clientId
        self.apiKey = config.apiKey
        self.authenticationMode = config.authenticationMode
        self.environment = config.environment
        self.configValues = config.configValues

        AppKit.shared.setup(configValues: config.configValues)
        URLProtocol.registerClass(CustomURLProtocol.self)

        API.POI.client.baseURL = Settings.shared.baseUrl(.poiApi)
        API.Pay.client.baseURL = Settings.shared.baseUrl(.payApi)

        API.POI.client.defaultHeaders = [HttpHeaderFields.userAgent.rawValue: Bundle.paceCloudSDK.poiKitUserAgent,
                                         HttpHeaderFields.apiKey.rawValue: apiKey ?? "Missing API key"]
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
        let clientId: String
        let apiKey: String
        let authenticationMode: AuthenticationMode
        let environment: Environment
        let configValues: [ConfigValue: Any]?

        public init(clientId: String,
                    apiKey: String,
                    authenticationMode: AuthenticationMode = .web,
                    environment: Environment = .production,
                    configValues: [ConfigValue: Any]? = nil) {
            self.clientId = clientId
            self.apiKey = apiKey
            self.authenticationMode = authenticationMode
            self.environment = environment
            self.configValues = configValues
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

    enum ConfigValue {
        case allowedLowAccuracy
    }
}
