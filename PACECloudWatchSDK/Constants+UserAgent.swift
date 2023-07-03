//
//  Constants+UserAgent.swift
//  PACECloudWatchSDK
//
//  Created by PACE Telematics GmbH.
//

import WatchKit

extension Constants {
    /**
     Creates a user agent for given project name with following format:
     `{client-app}/{client-app-version} ({os} {os-version}) Cloud-SDK/{cloud-sdk version})`
     */
    static var userAgent: String {
        let extensions = PACECloudSDK.shared.userAgentExtensions.joined(separator: " ")

        return [
            "\(Bundle.main.bundleNameWithoutWhitespaces)/\(Bundle.main.releaseVersionNumber)",
            "(\(WKInterfaceDevice.current().systemName) \(WKInterfaceDevice.current().systemVersion))",
            "Cloud-SDK/\(Bundle.paceCloudSDK.releaseVersionNumber)",
            extensions
        ].filter { !$0.isEmpty }.joined(separator: " ")
    }
}
