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

    var currentAppEnvironment: PACECloudSDK.Environment {
        #if PRODUCTION
        return .production
        #elseif SANDBOX
        return .sandbox
        #else
        return .development
        #endif
    }

    private var databaseUrl: URL {
        do {
            let fileManager = FileManager.default
            let appSupportURL = try fileManager.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true)
            let directoryURL = appSupportURL.appendingPathComponent("GeoDatabase", isDirectory: true)
            try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)

            let databaseURL = directoryURL.appendingPathComponent("db.sqlite")
            return databaseURL
        } catch {
            fatalError("[ExampleApp] Invalid geo database url")
        }
    }

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
        let config: PACECloudSDK.Configuration = .init(
            apiKey: "apikey",
            clientId: "cloud-sdk-example-app",
            geoDatabaseMode: .enabled(databaseUrl),
            environment: currentAppEnvironment,
            logLevel: .debug,
            persistLogs: true
        )

        PACECloudSDK.shared.setup(with: config)
    }
}
