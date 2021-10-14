//
//  Logger+Notification.swift
//  PACECloudWatchSDK
//
//  Created by PACE Telematics GmbH.
//

import WatchKit

// MARK: - Notification handling
internal extension Logger {
    static func addDidEnterBackgroundObserver() {
        NotificationCenter.default.addObserver(Logger.self, selector: #selector(handleDidEnterBackground), name: WKExtension.applicationDidEnterBackgroundNotification, object: nil)
    }

    static func removeDidEnterBackgroundObserver() {
        NotificationCenter.default.removeObserver(Logger.self, name: WKExtension.applicationDidEnterBackgroundNotification, object: nil)
    }
}
