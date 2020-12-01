//
//  URLDecomposer.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

struct URLDecomposer {
    private enum URLChars: String {
        case dot = "."
        case slash = "/"
        case amp = "&"
        case equals = "="
    }

    static func decomposeManifestUrl(with manifest: AppManifest?, appBaseUrl: String?) -> (url: String, params: [URLParam])? {
        guard let manifest = manifest,
            let appStartUrl = manifest.appStartUrl,
            let appBaseUrl = appBaseUrl else { return nil }

        switch appStartUrl {
        case URLChars.dot.rawValue:
            guard let relativeUrlToResource = URL(string: manifest.manifestUrl ?? "")?.deletingLastPathComponent().absoluteString else { return nil }
            return (relativeUrlToResource, [])

        case URLChars.slash.rawValue:
            return (appBaseUrl, [])

        case let urlString where urlString == URL(string: appStartUrl)?.absoluteString:
            return (urlString, [])

        default:
            return (appBaseUrl, determineParams(from: appStartUrl))
        }
    }

    static func decomposeQuery(_ query: String) -> [String: String] {
        let queryParams = query.components(separatedBy: URLChars.amp.rawValue)

        var queryItems: [String: String] = [:]
        for param in queryParams {
            let itemPair = param.components(separatedBy: URLChars.equals.rawValue)
            guard itemPair.count >= 2 else { continue }
            queryItems[itemPair[0]] = itemPair[1...].joined().removingPercentEncoding
        }

        return queryItems
    }

    private static func determineParams(from url: String) -> [URLParam] {
        let decomposedParams: [URLParam] = URLParam.appStartUrlParams.filter { url.contains($0.rawValue.uppercased()) }
        return decomposedParams
    }
}
