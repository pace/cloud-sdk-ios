//
//  QueryParamHandler.swift
//  PACECloudSDK
//
//  Created by Martin Dinh on 15.01.21.
//

import Foundation

class QueryParamHandler {
    private static let ignoredUrls: [String] = [
        Settings.shared.baseUrl(.search),
        Settings.shared.baseUrl(.reverseGeocode),
        Settings.shared.baseUrl(.osrm)
    ]

    static func buildUrl(for url: URL) -> URL? {
        guard !ignoredUrls.contains(where: url.absoluteString.contains),
              var urlComponents = URLComponents(string: url.absoluteString)
        else {
            return url
        }

        var queryItems: [URLQueryItem] = (urlComponents.queryItems ?? []) + (PACECloudSDK.shared.additionalQueryParams ?? [])

        // If there is no value for utm_source yet
        // use the main bundle's name if not empty
        let utmSource = "utm_source"
        let mainBundleName = Bundle.main.bundleNameWithOutWhitespaces

        if !mainBundleName.isEmpty,
           !queryItems.contains(where: { $0.name == utmSource }) {
            queryItems.append(.init(name: utmSource, value: mainBundleName))
        }

        urlComponents.queryItems = queryItems

        return urlComponents.url
    }
}
