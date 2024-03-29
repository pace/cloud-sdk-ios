//
//  Constants+UserAgent.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import UIKit

extension Constants {
    /**
     Creates a user agent for given project name with following format:
     `{client-app}/{client-app-version} ({os} {os-version}) Cloud-SDK/{cloud-sdk version} IdentityManagement/{authenticationMode} Cloud-SDK-Theme/{theme})`
     */
    static var userAgent: String {
        let authenticationMode: String = PACECloudSDK.shared.authenticationMode.rawValue

        let themeValue = String(describing: AppKit.shared.theme)
        let theme: String = "Cloud-SDK-Theme/\(themeValue)"

        let extensions = PACECloudSDK.shared.userAgentExtensions.joined(separator: " ")

        return [
            "\(Bundle.main.bundleNameWithoutWhitespaces)/\(Bundle.main.releaseVersionNumber)",
            "(\(UIDevice.current.systemName) \(UIDevice.current.systemVersion))",
            "Cloud-SDK/\(Bundle.paceCloudSDK.releaseVersionNumber)",
            "IdentityManagement/\(authenticationMode)",
            theme,
            extensions
        ].filter { !$0.isEmpty }.joined(separator: " ")
    }
}
