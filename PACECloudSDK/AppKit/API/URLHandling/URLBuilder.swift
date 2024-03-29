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

    static func buildAppManifestUrl(with baseUrlString: String) -> String? {
        guard var components = URLComponents(string: baseUrlString) else { return nil }

        components.queryItems = nil // Drop query items
        components.fragment = nil // Drop fragment
        let manifestUrl = components.url?.appendingPathComponent("manifest.json")

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

    static func buildAppIconUrl(baseUrl: String?, iconSrc: String?) -> URL? {
        guard let iconSrc = iconSrc else { return nil }

        if iconSrc.isAbsoluteURLString {
            return URL(string: iconSrc)
        }

        guard let baseUrl = baseUrl else { return nil }
        return URL(string: baseUrl)?.appendingPathComponent(iconSrc)
    }
}
