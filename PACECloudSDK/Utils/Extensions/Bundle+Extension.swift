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
        return [
            "\(Bundle.main.bundleName)/\(Bundle.main.releaseVersionNumber)",
            "(\(UIDevice.current.systemName) \(UIDevice.current.systemVersion))",
            "POIKit-iOS/\(releaseVersionNumber)_\(buildVersionNumber)"
        ].filter { !$0.isEmpty }.joined(separator: " ")
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
              let releaseVersion = fallbackPlist["ReleaseVersion"] as? String
        else {
            Logger.e("Fallback release version couldn't be retrieved")
            return "Unknown"
        }

        return releaseVersion
    }

    var fallbackBuildVersion: String {
        guard let fallbackPlistUrl = url(forResource: "FallbackVersions", withExtension: "plist"),
              let fallbackPlist = NSDictionary(contentsOf: fallbackPlistUrl),
              let bundleVersion = fallbackPlist["BuildVersion"] as? String
        else {
            Logger.e("Fallback build version couldn't be retrieved")
            return "Unknown"
        }

        return bundleVersion
    }

    var clientRedirectScheme: String? {
        guard let urlTypes = object(forInfoDictionaryKey: Bundle.urlTypesInfoPlistKey) as? [[String: Any]] else { return nil }
        let schemes = urlTypes.compactMap { $0[Bundle.urlSchemesInfoPlistKey] as? [String] }.flatMap { $0 }
        let scheme = schemes.first(where: { $0.hasPrefix("pace.") })
        return scheme ?? PACECloudSDK.shared.redirectScheme
    }

    var isCustomURLProtocolKeySet: Bool {
        object(forInfoDictionaryKey: Bundle.customURLProtocol) as? Bool ?? false
    }

    var oidConfigClientId: String? {
        guard let idKitSetup = object(forInfoDictionaryKey: Bundle.idKitSetupKey) as? [String: String],
              let value = idKitSetup[Bundle.oidConfigClientId], !value.isEmpty else { return nil }
        return value
    }

    var oidConfigRedirectUri: String? {
        guard let idKitSetup = object(forInfoDictionaryKey: Bundle.idKitSetupKey) as? [String: String],
              let value = idKitSetup[Bundle.oidConfigRedirectUri], !value.isEmpty else { return nil }
        return value
    }

    var oidConfigIdpHint: String? {
        guard let idKitSetup = object(forInfoDictionaryKey: Bundle.idKitSetupKey) as? [String: String],
              let value = idKitSetup[Bundle.oidConfigIdpHint], !value.isEmpty else { return nil }
        return value
    }
}

extension Bundle {
    static let urlTypesInfoPlistKey = "CFBundleURLTypes"
    static let urlSchemesInfoPlistKey = "CFBundleURLSchemes"

    static let customURLProtocol = "PACECloudSDKCustomURLProtocolEnabled"

    static let idKitSetupKey = "PACECloudSDKIDKitSetup"
    static let oidConfigClientId = "OIDConfigurationClientID"
    static let oidConfigRedirectUri = "OIDConfigurationRedirectURI"
    static let oidConfigIdpHint = "OIDConfigurationIDPHint"
}
