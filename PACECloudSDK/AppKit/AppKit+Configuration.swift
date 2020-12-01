//
//  AppKit+Configuration.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import UIKit

public extension AppKit {
    struct AppKitConfiguration {
        let clientId: String
        let apiKey: String?
        let authenticationMode: AuthenticationMode
        let accessToken: String?
        let theme: AppKitTheme
        let environment: AppEnvironment
        let configValues: [ConfigValue: Any]?

        public init(clientId: String,
                    apiKey: String? = nil,
                    authenticationMode: AuthenticationMode = .web,
                    accessToken: String? = nil,
                    theme: AppKitTheme = .automatic,
                    environment: AppEnvironment,
                    configValues: [ConfigValue: Any]? = nil) {
            self.clientId = clientId
            self.apiKey = apiKey
            self.authenticationMode = accessToken != nil ? .native : authenticationMode
            self.accessToken = accessToken
            self.theme = theme
            self.environment = environment
            self.configValues = configValues
        }
    }

    enum ConfigValue {
        case allowedLowAccuracy
    }

    enum AppKitTheme: CustomStringConvertible {
        case dark
        case light
        case automatic

        public var description: String {
            switch self {
            case .dark:
                return "Dark"

            case .light:
                return "Light"

            case .automatic:
                if #available(iOS 13.0, *) {
                    return UITraitCollection.current.userInterfaceStyle == .light ? "\(AppKitTheme.light)" : "\(AppKitTheme.dark)"
                } else {
                    return "\(AppKitTheme.light)"
                }
            }
        }

        public var isDarkTheme: Bool {
            description == AppKitTheme.dark.description
        }
    }

    enum AuthenticationMode: String {
        case native
        case web
    }

    enum AppEnvironment: String {
        case development = "dev"
        case sandbox = "sandbox"
        case stage = "stage"
        case production = "prod"
    }
}
