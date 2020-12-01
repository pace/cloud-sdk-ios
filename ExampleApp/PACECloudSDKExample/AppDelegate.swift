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
        appCoordinator = AppCoordinator()
        window?.rootViewController = appCoordinator?.navigationController
        window?.makeKeyAndVisible()
        appCoordinator?.start()

        return true
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
