//
//  PACECloudSDKExampleApp.swift
//  PACECloudSDKExample
//
//  Created by PACE Telematics GmbH.
//

import PACECloudSDK
import SwiftUI

@main
struct PACECloudSDKExampleApp: App {
    @ObservedObject private var idControl = IDControl.shared

    init() {
        #if TOKEN_EXCHANGE
        let exchangeConfig = IDKit.TokenExchangeConfiguration(exchangeClientID: "cloud-sdk-example-app-token-exchange",
                                                              exchangeIssuerID: "multi-oidc",
                                                              exchangeClientSecret: "IMqeEWNd91lOf9tCEnIFZyOwcnDNV6Jw")

        let oidConfig = IDKit.OIDConfiguration(authorizationEndpoint: "https://id.dev.pace.cloud/auth/realms/MultiRealm/protocol/openid-connect/auth",
                                               tokenEndpoint: "https://id.dev.pace.cloud/auth/realms/MultiRealm/protocol/openid-connect/token",
                                               clientId: "cloud-sdk-example-app",
                                               clientSecret: "YIUXbpLZeN6OD1afjXwD4lFZigQAIHp7",
                                               redirectUri: "cloud-sdk-example://callback",
                                               tokenExchangeConfig: exchangeConfig)
        PACECloudSDK.shared.setup(
            with: .init(
                apiKey: "connected-fueling-app",
                clientId: "cloud-sdk-example-app",
                environment: currentAppEnvironment,
                customOIDConfiguration: oidConfig,
                domainACL: ["pace.cloud", "pacelink.net", "fuel.site"],
                logLevel: .debug,
                persistLogs: true
            )
        )
        #else
        let config: PACECloudSDK.Configuration = .init(apiKey: "apikey",
                                                       clientId: "cloud-sdk-example-app",
                                                       environment: currentAppEnvironment,
                                                       domainACL: ["pace.cloud", "pacelink.net", "fuel.site"],
                                                       logLevel: .debug,
                                                       persistLogs: true)

        PACECloudSDK.shared.setup(with: config)
        #endif
        IDControl.shared.refresh()
    }

    var body: some Scene {
        WindowGroup {
            if idControl.isRefreshing {
                LoadingSpinner(loadingText: "Logging in...")
            } else if idControl.isSessionValid {
                MainTabView().onOpenURL { url in
                    PACECloudSDK.shared.application(open: url)
                }
            } else {
                LoginView()
            }
        }
    }
}

var currentAppEnvironment: PACECloudSDK.Environment {
    #if PRODUCTION
    return .production
    #elseif SANDBOX
    return .sandbox
    #else
    return .development
    #endif
}
