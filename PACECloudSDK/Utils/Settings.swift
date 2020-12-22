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
    private(set) var osrmBaseUrl = ""
    private(set) var searchBaseUrl = ""
    private(set) var reverseGeocodeBaseUrl = ""
    private(set) var tileBaseUrl = ""
    private(set) var tilesApiUrl = ""

    private let environmentPrefix = "Environment"
    private let apiGatewayKey = "ApiGateway"
    private let osrmBaseUrlKey = "OsrmBaseUrl"
    private let searchBaseUrlKey = "SearchBaseUrl"
    private let reverseGeocodeBaseUrlKey = "ReverseGeocodeBaseUrl"
    private let tileBaseUrlKey = "TileBaseUrl"
    private let tilesApiUrlKey = "TilesApiUrl"

    struct SettingsBundleKeys {
        static let AppVersionKey = "AppVersionAndBuild"
    }

    private init() {
        setupEnvironment(for: PACECloudSDK.shared.environment)
    }

    private func setupEnvironment(for environment: PACECloudSDK.Environment) {
        let environmentKey = "\(environmentPrefix)-\(environment.rawValue)"

        guard let path = Bundle.paceCloudSDK.path(forResource: environmentKey, ofType: "plist"),
              let settings = NSDictionary(contentsOfFile: path) as? [String: String] else { return }

        apiGateway = settings[apiGatewayKey]!
        poiApiHostUrl = URL(string: apiGateway)!.appendingPathComponent("poi").absoluteString
        osrmBaseUrl = settings[osrmBaseUrlKey]!
        searchBaseUrl = settings[searchBaseUrlKey]!
        reverseGeocodeBaseUrl = settings[reverseGeocodeBaseUrlKey]!
        tileBaseUrl = settings[tileBaseUrlKey]!
        tilesApiUrl = settings[tilesApiUrlKey]!
    }

    func baseUrl(_ type: POIKitBaseUrl) -> String {
        switch type {
        case .poiApi:
            return poiApiHostUrl

        case .osrm:
            return osrmBaseUrl

        case .search:
            return searchBaseUrl

        case .reverseGeocode:
            return reverseGeocodeBaseUrl

        case .tilesServer:
            return tileBaseUrl

        case .tilesApi:
            return tilesApiUrl
        }
    }

    enum POIKitBaseUrl {
        case osrm
        case search
        case reverseGeocode
        case tilesServer
        case tilesApi
        case poiApi
    }
}