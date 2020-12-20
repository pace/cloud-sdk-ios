//
//  PACECloudSDK.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

public class PACECloudSDK {
    public static let shared = PACECloudSDK()

    private(set) public lazy var poiKitManager: POIKit.POIKitManager = .init(environment: .production)

    private(set) var environment: Environment = .production
    private(set) var authenticationMode: AuthenticationMode = .web
    private(set) var configValues: [ConfigValue: Any]?
    private(set) var userAgentExtensions: [String] = []

    private(set) var apiKey: String?
    private(set) var clientId: String?
    var initialAccessToken: String?
    var currentAccessToken: String?

    private init() {}

    public func setup(with config: Configuration) {
        self.clientId = config.clientId
        self.apiKey = config.apiKey
        self.authenticationMode = config.authenticationMode
        self.initialAccessToken = config.accessToken
        self.currentAccessToken = config.accessToken
        self.environment = config.environment
        self.configValues = config.configValues

        AppKit.shared.setup(configValues: config.configValues)
        poiKitManager = POIKit.POIKitManager.init(environment: config.environment)
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
        let accessToken: String?
        let environment: Environment
        let configValues: [ConfigValue: Any]?

        public init(clientId: String,
                    apiKey: String,
                    authenticationMode: AuthenticationMode = .web,
                    accessToken: String? = nil,
                    environment: Environment = .production,
                    configValues: [ConfigValue: Any]? = nil) {
            self.clientId = clientId
            self.apiKey = apiKey
            self.authenticationMode = accessToken != nil ? .native : authenticationMode
            self.accessToken = accessToken
            self.environment = environment
            self.configValues = configValues
        }
    }

    enum Environment: String {
        case development
        case sandbox
        case stage
        case production
    }

    enum AuthenticationMode: String {
        case native
        case web
    }

    enum ConfigValue {
        case allowedLowAccuracy
    }
}
