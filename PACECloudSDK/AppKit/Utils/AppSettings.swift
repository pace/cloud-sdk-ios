//
//  AppSettings.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

class AppSettings {
    static let shared = AppSettings()

    private(set) var idGateway: String = ""
    private(set) var cloudGateway: String = ""

    private let appSettingsKey = "AppSettings"
    private let environmentPrefix = "Environment"
    private let idGatewayKey = "IdGateway"
    private let cloudGatewayKey = "CloudGateway"

    struct SettingsBundleKeys {
        static let AppVersionKey = "AppVersionAndBuild"
    }

    private init() {
        guard let environment = AppKit.shared.environment else { return }
        setupEnvironment(for: environment)
    }

    private func setupEnvironment(for environment: AppKit.AppEnvironment) {
        let environmentKey = "\(environmentPrefix)-\(environment.rawValue)"

        guard let path = Bundle.paceCloudSDK.path(forResource: environmentKey, ofType: "plist"),
              let settings = NSDictionary(contentsOfFile: path) as? [String: String] else { return }

        idGateway = settings[idGatewayKey] ?? ""
        cloudGateway = settings[cloudGatewayKey] ?? ""
    }
}
