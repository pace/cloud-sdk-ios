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

    /**
     Creates a user agent for given project name with following format:
     `{client-app}/{client-app-version} ({os} {os-version}) PWA-SDK/{app-sdk version} (clientid:{client-id};)`
     */
    static var userAgent: String {
        let authenticationMode: String = PACECloudSDK.shared.authenticationMode.rawValue

        let themeValue = String(describing: AppKit.shared.theme)
        let theme: String = "PWASDK-Theme/\(themeValue)"

        let extensions = PACECloudSDK.shared.userAgentExtensions.joined(separator: " ")

        return [
            "\(Bundle.main.bundleNameWithoutWhitespaces)/\(Bundle.main.releaseVersionNumber)",
            "(\(UIDevice.current.systemName) \(UIDevice.current.systemVersion))",
            "PWA-SDK/\(Bundle.paceCloudSDK.releaseVersionNumber)",
            "IdentityManagement/\(authenticationMode)",
            theme,
            extensions
        ].filter { !$0.isEmpty }.joined(separator: " ")
    }

    static var userAgentHeader: [String: String] {
        return [HttpHeaderFields.userAgent.rawValue: userAgent]
    }

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
