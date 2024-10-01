//
//  QueryParamUTMHandler.swift
//  PACECloudSDK
//
//  Created by Martin Dinh on 15.01.21.
//

import Foundation

public extension PACECloudSDK {
    enum QueryParamUTMHandler {
        public static func buildUrl(for url: Foundation.URL) -> Foundation.URL? {
            guard var urlComponents = URLComponents(string: url.absoluteString)
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
}
