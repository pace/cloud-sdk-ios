//
//  Bundle+Extension.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import UIKit

extension Bundle {
    var releaseVersionNumber: String {
        guard let version = self.infoDictionary?["CFBundleShortVersionString"] as? String else { return "" }
        return version
    }

    var buildVersionNumber: String {
        guard let version = self.infoDictionary?["CFBundleVersion"] as? String else { return "" }
        return version
    }

    var poiKitUserAgent: String {
        "POIKit-iOS/\(releaseVersionNumber).\(buildVersionNumber) " +
        "(\(UIDevice.current.modelIdentifier); " +
        "\(UIDevice.current.systemName)/\(UIDevice.current.systemVersion))"
    }

    var versionString: String {
        return "\(self.releaseVersionNumber).\(self.buildVersionNumber)"
    }

    var bundleName: String {
        guard let name = self.infoDictionary?["CFBundleName"] as? String else { return bundleIdentifier ?? "" }
        return name.components(separatedBy: .whitespaces).joined()
    }
}
