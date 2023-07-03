//
//  AppKitConstants.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import NotificationCenter
import UIKit

public extension AppKit {
    struct Constants {}
}

extension AppKit.Constants {
    static let logTag = "[AppKit]"

    static var currentLanguageCode: String? {
        return Locale.current.languageCode
    }

    // MARK: - Notifications
    struct NotificationIdentifier {
        static let caughtRedirectService: NSNotification.Name = NSNotification.Name("notification.caughtRedirectService")
    }

    struct RedirectServiceParams {
        static let url: String = "url"
    }
}

public extension AppKit.Constants {
    static let appCloseRedirectUri = "cloudsdk://close"
}
