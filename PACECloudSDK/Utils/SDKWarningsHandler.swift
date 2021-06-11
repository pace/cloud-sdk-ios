//
//  SDKWarningsHandler.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

extension PACECloudSDK {
    struct SDKWarningsHandler {
        private let apiKey: String
        private let redirectScheme: String?
        private let environment: Environment
        private let customOIDConfiguration: IDKit.OIDConfiguration?
        private let domainACL: [String]?
        private let isRedirectSchemeCheckEnabled: Bool

        init(with config: PACECloudSDK.Configuration) {
            self.apiKey = config.apiKey
            self.redirectScheme = Bundle.main.clientRedirectScheme
            self.environment = config.environment
            self.customOIDConfiguration = config.customOIDConfiguration
            self.domainACL = config.domainACL

            self.isRedirectSchemeCheckEnabled = config.isRedirectSchemeCheckEnabled
        }

        func preCheckSetup() {
            guard [isSDKSetupValuesAvailable, isIDKitSetupCorrect].filter({ !$0 }).isEmpty else {
                logSDKWarningsIfNeeded()
                return
            }

            var message = "\n✅ PACECloudSDK setup successful. You are currently running the SDK as follows:"
            message += sdkSetupSuccessfulMessage
            message += idKitSetupSuccessfulMessage

            Logger.i(message)
        }

        func logSDKWarningsIfNeeded() {
            guard [isSDKSetupValuesAvailable, isIDKitSetupCorrect].contains(where: { !$0 }) else { return }

            var warningMessage = "\n❌ We've noticed some inconsistencies with your PACECloudSDK setup!"

            if !isSDKSetupValuesAvailable {
                warningMessage += sdkSetupFailedMessage
            }

            if !isIDKitSetupCorrect {
                warningMessage += idKitSetupFailedMessage
            }

            Logger.w(warningMessage)
        }

        func logBiometryWarningsIfNeeded() {
            guard domainACL?.isEmpty ?? true else { return }
            Logger.w("\n⚠️ We've noticed that you are using IDKit's 2FA methods but haven't set up a valid 'domainACL' yet. Please do so in your PACECloudSDK's configuration.")
        }
    }
}

// MARK: - General SDK setup
private extension PACECloudSDK.SDKWarningsHandler {
    var missingValues: [String] {
        var missingValues: [String] = []

        if apiKey.isEmpty {
            missingValues.append("API key")
        }

        if isRedirectSchemeCheckEnabled && redirectScheme?.isEmpty ?? true {
            missingValues.append("Redirect scheme")
        }

        return missingValues
    }

    var isSDKSetupValuesAvailable: Bool {
        missingValues.isEmpty
    }

    var sdkSetupSuccessfulMessage: String {
        var message = "\nAPI key is set"

        if isRedirectSchemeCheckEnabled, let redirectScheme = self.redirectScheme {
            message += "\nRedirect scheme: '\(redirectScheme)'"
        }

        let envWarning = environment != .production ? "⚠️ " : ""
        message += "\nEnvironment: \(envWarning)'\(environment.rawValue)'"

        return message
    }

    var sdkSetupFailedMessage: String {
        "\nThe SDK setup is missing values for: [\(missingValues.joined(separator: ", "))]."
    }
}

// MARK: - IDKit setup
private extension PACECloudSDK.SDKWarningsHandler {
    var isIDKitSetupCorrect: Bool {
        let oidClientId = Bundle.main.oidConfigClientId
        let oidRedirectUri = Bundle.main.oidConfigRedirectUri

        if customOIDConfiguration != nil {
            return true
        }

        return [oidClientId, oidRedirectUri].compactMap { $0 }.count != 1 // If there is no custom config and only one plist value is set -> failure
    }

    var idKitSetupSuccessfulMessage: String {
        var message = "\nIDKit oid configuration:"

        if customOIDConfiguration != nil {
            message += " custom"
        } else if Bundle.main.oidConfigClientId != nil, Bundle.main.oidConfigRedirectUri != nil {
            message += " default"
        } else {
            message += " none"
        }

        return message
    }

    var idKitSetupFailedMessage: String {
        """
        \nIf you want to use the default IDKit oid configuration please make sure to add both `PACECloudSDKOIDConfigurationClientID` \
        and `PACECloudSDKOIDConfigurationRedirectURI` with non-empty values to your Info.plist.
        """
    }
}
