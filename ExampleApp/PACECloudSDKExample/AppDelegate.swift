//
//  AppDelegate.swift
//  PACECloudSDKExample
//
//  Created by Patrick Niepel on 05.11.20.
//

import CoreLocation
import PACECloudSDK
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var appCoordinator: AppCoordinator?
    var locationManager: CLLocationManager?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool { // swiftlint:disable:this line_length
        window = UIWindow()

        let config: PACECloudSDK.Configuration = .init(apiKey: "apikey",
                                                       authenticationMode: .native,
                                                       environment: currentAppEnvironment(),
                                                       domainACL: ["pace.cloud"],
                                                       geoAppsScope: "pace-drive-ios")

        PACECloudSDK.shared.setup(with: config)

        appCoordinator = AppCoordinator()
        window?.rootViewController = appCoordinator?.navigationController
        window?.makeKeyAndVisible()
        appCoordinator?.start()

        return true
    }

    private func currentAppEnvironment() -> PACECloudSDK.Environment {
        #if PRODUCTION
        return .production
        #elseif STAGE
        return .stage
        #elseif SANDBOX
        return .sandbox
        #else
        return .development
        #endif
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        switch url.host {
        case "redirect":
            AppControl.shared.handleRedirectURL(url)
            return true

        default:
            return false
        }
    }
}
