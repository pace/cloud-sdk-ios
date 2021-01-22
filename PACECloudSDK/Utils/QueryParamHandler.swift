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

        if var params = PACECloudSDK.shared.additionalQueryParams {
            params = includePartnerClient(in: params)

            urlComponents.queryItems = queryItems + Array(params)
        } else {
            urlComponents.queryItems = queryItems + Array(includePartnerClient(in: []))
        }

        return urlComponents.url
    }

    private static func includePartnerClient(in params: Set<URLQueryItem>) -> Set<URLQueryItem> {
        guard !params.contains(where: { $0.name == URLParam.utmPartnerClient.rawValue }) else { return params }

        let partnerQueryItem = URLQueryItem(name: URLParam.utmPartnerClient.rawValue,
                                            value: Bundle.main.bundleName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))

        return params.union([partnerQueryItem])
    }
}
