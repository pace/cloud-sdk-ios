//
//  Logger+Notification.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import UIKit

// MARK: - Notification handling
internal extension Logger {
    static func addDidEnterBackgroundObserver() {
        NotificationCenter.default.addObserver(Logger.self, selector: #selector(handleDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }

    static func removeDidEnterBackgroundObserver() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
}
