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
        guard !ignoredUrls.contains(where: url.absoluteString.contains) else { return url }

        guard var urlComponents = URLComponents(string: url.absoluteString) else { return url }

        let queryItems: [URLQueryItem] = urlComponents.queryItems ?? []

        if let params = PACECloudSDK.shared.additionalQueryParams {
            urlComponents.queryItems = queryItems + Array(params)
        }

        return urlComponents.url
    }
}
