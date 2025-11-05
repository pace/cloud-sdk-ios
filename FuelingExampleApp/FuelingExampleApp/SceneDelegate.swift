//
//  SceneDelegate.swift
//  FuelingExampleApp
//
//  Created by PACE Telematics GmbH.
//

import PACECloudSDK
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let viewController = LoginViewController(viewModel: LoginViewModelImplementation())
        let navigation = UINavigationController(rootViewController: viewController)
        navigation.navigationBar.prefersLargeTitles = true
        navigation.view.backgroundColor = .white

        setupPACECloudSDK()

        self.window = UIWindow(windowScene: windowScene)
        window?.rootViewController = navigation
        window?.makeKeyAndVisible()
    }

    func setupPACECloudSDK() {
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
                logLevel: .debug,
                persistLogs: true
            )
        )
        #else
        let config: PACECloudSDK.Configuration = .init(
            apiKey: "apikey",
            clientId: "cloud-sdk-example-app",
            environment: currentAppEnvironment,
            logLevel: .debug,
            persistLogs: true
        )

        PACECloudSDK.shared.setup(with: config)
        #endif

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
}
