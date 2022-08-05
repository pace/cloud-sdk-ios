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

        let utmSource = "utm_source"
        let queryItems: [URLQueryItem] = (urlComponents.queryItems ?? [])
        let filteredCustomQueryParams = (PACECloudSDK.shared.additionalQueryParams ?? []).filter {
            !($0.name == utmSource && queryItems.contains(where: { $0.name == utmSource }))
        }

        var newQueryItems: [URLQueryItem] = queryItems + filteredCustomQueryParams

        // If there is no value for utm_source yet
        // use the main bundle's name if not empty
        let mainBundleName = Bundle.main.bundleNameWithoutWhitespaces

        if !mainBundleName.isEmpty,
           !newQueryItems.contains(where: { $0.name == utmSource }) {
            newQueryItems.append(.init(name: utmSource, value: mainBundleName))
        }

        urlComponents.queryItems = newQueryItems

        return urlComponents.url
    }
}
