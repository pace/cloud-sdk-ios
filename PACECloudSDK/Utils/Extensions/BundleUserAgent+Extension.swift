//
//  BundleUserAgent+Extension.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import UIKit

extension Bundle {
    var poiKitUserAgent: String {
        return [
            "\(Bundle.main.bundleName)/\(Bundle.main.releaseVersionNumber)",
            "(\(UIDevice.current.systemName) \(UIDevice.current.systemVersion))",
            "POIKit-iOS/\(releaseVersionNumber)_\(buildVersionNumber)"
        ].filter { !$0.isEmpty }.joined(separator: " ")
    }
}
