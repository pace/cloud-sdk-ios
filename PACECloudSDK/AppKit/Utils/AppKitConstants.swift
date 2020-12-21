//
//  AppKitConstants.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import NotificationCenter
import UIKit

struct AppKitConstants {
    static let bundleIdentifier = "cloud.pace.sdk"
    static let logTag = "[AppKit]"

    /**
    Creates a user agent for given project name with following format:
    `{client-app}/{client-app-version} ({os} {os-version}) PWA-SDK/{app-sdk version} (clientid:{client-id};)`
    */
    static var userAgent: String {
        let clientId: String = PACECloudSDK.shared.clientId ?? "Missing client id"
        let authenticationMode: String = PACECloudSDK.shared.authenticationMode.rawValue

        let themeValue = String(describing: AppKit.shared.theme)
        let theme: String = "PWASDK-Theme/\(themeValue)"

        let extensions = PACECloudSDK.shared.userAgentExtensions.joined(separator: " ")

        return [
            "\(Bundle.main.bundleName)/\(Bundle.main.releaseVersionNumber)",
            "(\(UIDevice.current.systemName) \(UIDevice.current.systemVersion))",
            "PWA-SDK/\(Bundle.paceCloudSDK.releaseVersionNumber)",
            "(clientid:\(clientId);)",
            "IdentityManagement/\(authenticationMode)",
            theme,
            extensions
        ].filter { !$0.isEmpty }.joined(separator: " ")
    }

    static var userAgentHeader: [String: String] {
        return ["User-Agent": AppKitConstants.userAgent]
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
