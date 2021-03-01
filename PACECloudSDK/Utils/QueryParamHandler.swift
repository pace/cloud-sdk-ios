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
        guard let additionalQueryParams = PACECloudSDK.shared.additionalQueryParams,
              !ignoredUrls.contains(where: url.absoluteString.contains),
              var urlComponents = URLComponents(string: url.absoluteString)
        else {
            return url
        }

        let queryItems: [URLQueryItem] = urlComponents.queryItems ?? []

        urlComponents.queryItems = queryItems + Array(additionalQueryParams)

        return urlComponents.url
    }
}
