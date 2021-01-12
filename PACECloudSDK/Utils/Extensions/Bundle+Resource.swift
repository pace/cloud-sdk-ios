//
//  Bundle+Resource.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

private class MyBundleFinder {}

public extension Bundle {
    static var paceCloudSDK: Bundle {
        Bundle.resource
    }

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
