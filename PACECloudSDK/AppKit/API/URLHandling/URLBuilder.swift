//
//  URLBuilder.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

struct URLBuilder {
    static func buildBaseQueryComponent(for data: BaseQueryParams) -> URLComponents? {
        let stateItem = URLQueryItem(name: URLParam.state.rawValue, value: data.state)
        let statusItem: URLQueryItem? = data.statusCode.map { URLQueryItem(name: URLParam.status.rawValue, value: "\($0)") }
        var component = URLComponents(string: data.redirectUri)
        component?.queryItems = [stateItem, statusItem].compactMap { $0 }

        return component
    }

    static func buildAppManifestUrl(with baseUrl: String?) -> String? {
        guard let baseUrlString = baseUrl, let baseUrl = URL(string: baseUrlString) else { return nil }

        var manifestUrl: URL? {
            var components = URLComponents()
            components.scheme = baseUrl.scheme
            components.host = baseUrl.host
            components.port = baseUrl.port
            components.path = "/manifest.json"
            return components.url
        }

        return manifestUrl?.absoluteString
    }

    // hem id: e3211b77-03f0-4d49-83aa-4adaa46d95ae
    // fsc id: f582e5b4-5424-453f-9d7d-8c106b8360d3
    static func buildAppStartUrl(with url: String?, decomposedParams: [URLParam], references: String?) -> String? {
        guard let url = url, var urlComponent = URLComponents(string: url) else { return nil }

        let queryItems: [URLQueryItem] = decomposedParams.compactMap { param in
            let key = param.rawValue
            var value: String?

            switch param {
            case .references:
                value = references

            default:
                value = nil
            }

            guard let unwrappedValue = value else { return nil }

            return URLQueryItem(name: key, value: unwrappedValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))
        }

        if !queryItems.isEmpty {
            urlComponent.queryItems = queryItems
        }

        return urlComponent.url?.absoluteString
    }

    static func buildAppIconUrl(baseUrl: String?, iconSrc: String?) -> String? {
        guard let baseUrl = baseUrl,
            let iconSrc = iconSrc else { return nil }

        return baseUrl + "/" + iconSrc
    }
}
