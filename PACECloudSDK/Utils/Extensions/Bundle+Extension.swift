//
//  Bundle+Extension.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import UIKit

extension Bundle {
    var releaseVersionNumber: String {
        guard let version = self.infoDictionary?["CFBundleShortVersionString"] as? String else { return fallbackReleaseVersion }
        return version
    }

    var buildVersionNumber: String {
        guard let version = self.infoDictionary?["CFBundleVersion"] as? String else { return fallbackBuildVersion }
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

    var fallbackReleaseVersion: String {
        guard let fallbackPlistUrl = url(forResource: "FallbackVersions", withExtension: "plist"),
              let fallbackPlist = NSDictionary(contentsOf: fallbackPlistUrl),
              let releaseVersion = fallbackPlist["ReleaseVersion"] as? String else { fatalError() }

        return releaseVersion
    }

    var fallbackBuildVersion: String {
        guard let fallbackPlistUrl = url(forResource: "FallbackVersions", withExtension: "plist"),
              let fallbackPlist = NSDictionary(contentsOf: fallbackPlistUrl),
              let bundleVersion = fallbackPlist["BuildVersion"] as? String else { fatalError() }

        return bundleVersion
    }
}
