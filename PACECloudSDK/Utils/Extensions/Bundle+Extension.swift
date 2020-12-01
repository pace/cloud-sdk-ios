//
//  Bundle+Extension.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import UIKit

extension Bundle {
    static var paceCloudSDK: Bundle {
        Bundle.resource
    }

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

private class MyBundleFinder {}

extension Bundle {
    /**
     The resource bundle associated with the current module.
     - important: When `PACECloudSDK` is distributed via Swift Package Manager, it will be synthesized automatically in the name of `Bundle.module`.
     */
    static var resource: Bundle = {
        let moduleName = "PACECloudSDK"
        #if COCOAPODS
        let bundleName = moduleName
        #else
        let bundleName = "\(moduleName)_\(moduleName)"
        #endif

        let resourceUrls = [
            // Bundle should be present here when the package is linked into an App.
            Bundle.main.resourceURL,
            // Bundle should be present here when the package is linked into a framework.
            Bundle(for: MyBundleFinder.self).resourceURL,

            // For command-line tools.
            Bundle.main.bundleURL
        ]

        for case let url? in resourceUrls {
            let bundlePath = url.appendingPathComponent(bundleName + ".bundle")

            guard let bundle = Bundle(url: bundlePath) else { continue }

            return bundle
        }

        guard let bundle = Bundle(identifier: "cloud.pace.sdk") else { fatalError("Unable to find bundle named \(bundleName)") }

        return bundle
    }()
}
