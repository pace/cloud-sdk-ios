//
//  AppKit+AppManagerDelegate.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import CoreLocation
import Foundation

extension AppKit: AppManagerDelegate {
    func didEnterGeofence(with id: String) {
        notifyDidEnterGeofence(with: id)
    }

    func didExitGeofence(with id: String) {
        notifyDidExitGeofence(with: id)
    }

    func didFailToMonitorRegion(_ region: CLRegion, error: Error) {
        notifyDidFailToMonitorRegion(region, error: error)
    }

    func passErrorToClient(_ error: AppError) {
        notifyDidFail(with: error)
    }

    func didReceiveAppDatas(_ appDatas: [AppData]) {
        // Filter out Apps that should not be shown
        let filteredAppData: [AppData] = appDatas.filter {
            guard let urlHost = URL(string: $0.appBaseUrl ?? "")?.host,
                  let disableTime: Double = UserDefaults.standard.value(forKey: "disable_time_\(urlHost)") as? Double
            else {
                return true
            }

            if Date().timeIntervalSince1970 >= disableTime {
                AppKitLogger.i("Disable timer for \(urlHost) has been reached.")
                UserDefaults.standard.removeObject(forKey: "disable_time_\(urlHost)")

                return true
            }

            AppKitLogger.i("Don't show \(urlHost), because disable timer has not been reached.")
            return false
        }

        let appDrawers = filteredAppData.map { AppDrawer(with: $0) }
        notifyDidReceiveAppDrawerContainer(appDrawers, filteredAppData)
    }

    func didEscapeForecourt(_ appDatas: [AppData]) {
        notifyDidEscapeForecourt(appDatas)
    }
}
