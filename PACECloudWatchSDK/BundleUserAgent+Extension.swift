//
//  BundleUserAgent+Extension.swift
//  PACECloudWatchSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

extension Bundle {
    var poiKitUserAgent: String {
        return [
            "\(Bundle.main.bundleNameWithoutWhitespaces)/\(Bundle.main.releaseVersionNumber)",
            "POIKit-iOS/\(releaseVersionNumber)_\(buildVersionNumber)"
        ].filter { !$0.isEmpty }.joined(separator: " ")
    }
}
