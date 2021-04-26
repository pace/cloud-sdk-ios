//
//  SDKWarningsHandler.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

extension PACECloudSDK {
    struct SDKWarningsHandler {
        let apiKey: String
        let redirectScheme: String?
        let environment: Environment

        let isRedirectSchemeCheckEnabled: Bool

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

        init(with config: PACECloudSDK.Configuration) {
            self.apiKey = config.apiKey
            self.redirectScheme = Bundle.main.clientRedirectScheme
            self.environment = config.environment

            self.isRedirectSchemeCheckEnabled = config.isRedirectSchemeCheckEnabled
        }

        func preCheckSetup() {
            if missingValues.isEmpty {
                let apiKeyMessage = "\nAPI key is set"

                var redirectMessage: String = ""
                if isRedirectSchemeCheckEnabled, let redirectScheme = self.redirectScheme {
                    redirectMessage = "\nRedirect scheme: '\(redirectScheme)'"
                }

                let envWarning = environment != .production ? "⚠️ " : ""
                let envMessage = "\nEnvironment: \(envWarning)'\(environment.rawValue)'"

                Logger.i("\n✅ PACECloudSDK setup successful. You are currently running the SDK as follows:\(apiKeyMessage)\(redirectMessage)\(envMessage)")
            } else {
                Logger.w("\n❌ PACECloudSDK setup is missing values for: [\(missingValues.joined(separator: ", "))].")
            }
        }

        func logSDKWarningsIfNeeded() {
            guard !missingValues.isEmpty else { return }
            Logger.w("\n❌ You haven't set any PACECloudSDK values for: [\(missingValues.joined(separator: ", "))].")
        }
    }
}
