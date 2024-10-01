//
//  Settings.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

// swiftlint:disable force_unwrapping
class Settings {
    static let shared = Settings()

    private(set) var apiGateway = ""
    private(set) var poiApiHostUrl = ""
    private(set) var payApiHostUrl = ""
    private(set) var fuelingApiHostUrl = ""
    private(set) var userApiHostUrl = ""
    private(set) var geoApiHostUrl = ""
    private(set) var priceServiceApiHostUrl = ""
    private(set) var cdnBaseUrl = ""

    private let environmentPrefix = "Environment"
    private let apiGatewayKey = "ApiGateway"
    private let cdnBaseUrlKey = "CDNBaseUrl"

    // MARK: - OIDConfiguration
    private let oidConfigurationKey = "OIDConfiguration"
    private let authorizationEndpoint = "AuthorizationEndpoint"
    private let tokenEndpoint = "TokenEndpoint"
    private let userEndpoint = "UserEndpoint"
    private let endSessionEndpoint = "EndSessionEndpoint"

    private(set) var authorizationEndpointUrl = ""
    private(set) var tokenEndpointUrl = ""
    private(set) var userEndpointUrl = ""
    private(set) var endSessionEndpointUrl = ""

    struct SettingsBundleKeys {
        static let AppVersionKey = "AppVersionAndBuild"
    }

    private init() {
        setupEnvironment(for: PACECloudSDK.shared.environment)
        setupOIDConfiguration(for: PACECloudSDK.shared.environment)
    }

    private func setupEnvironment(for environment: PACECloudSDK.Environment) {
        let environmentKey = "\(environmentPrefix)-\(environment.rawValue)"

        guard let path = Bundle.paceCloudSDK.path(forResource: environmentKey, ofType: "plist"),
              let settings = NSDictionary(contentsOfFile: path) as? [String: String] else { return }

        apiGateway = settings[apiGatewayKey]!
        poiApiHostUrl = URL(string: apiGateway)!.appendingPathComponent("poi").absoluteString
        payApiHostUrl = URL(string: apiGateway)!.appendingPathComponent("pay").absoluteString
        fuelingApiHostUrl = URL(string: apiGateway)!.appendingPathComponent("fueling").absoluteString
        userApiHostUrl = URL(string: apiGateway)!.appendingPathComponent("user").absoluteString
        priceServiceApiHostUrl = URL(string: apiGateway)!.appendingPathComponent("price-service").absoluteString
        cdnBaseUrl = settings[cdnBaseUrlKey]!
        geoApiHostUrl = URL(string: cdnBaseUrl)!.appendingPathComponent("geo").absoluteString
    }

    private func setupOIDConfiguration(for environment: PACECloudSDK.Environment) {
        let environmentKey = "\(environmentPrefix)-\(environment.rawValue)"

        guard let path = Bundle.paceCloudSDK.path(forResource: environmentKey, ofType: "plist"),
              let settings = NSDictionary(contentsOfFile: path) as? [String: String] else { return }

        authorizationEndpointUrl = settings[authorizationEndpoint]!
        tokenEndpointUrl = settings[tokenEndpoint]!
        userEndpointUrl = settings[userEndpoint]!
        endSessionEndpointUrl = settings[endSessionEndpoint]!
    }

    func baseUrl(_ type: POIKitBaseUrl) -> String {
        switch type {
        case .poiApi:
            return poiApiHostUrl

        case .payApi:
            return payApiHostUrl

        case .fuelingApi:
            return fuelingApiHostUrl

        case .userApi:
            return userApiHostUrl

        case .geo:
            return geoApiHostUrl

        case .priceService:
            return priceServiceApiHostUrl

        case .cdn:
            return cdnBaseUrl
        }
    }

    enum POIKitBaseUrl {
        case poiApi
        case payApi
        case fuelingApi
        case userApi
        case geo
        case priceService
        case cdn
    }
}
