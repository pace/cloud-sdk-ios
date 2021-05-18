//
//  URLRequestBuilder.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

struct URLRequestBuilder {
    static func buildRequest(with urlString: String, additionalHeaders: [String: String]?) -> URLRequest? {
        guard let url = URL(string: urlString), let urlWithQueryParams = QueryParamHandler.buildUrl(for: url) else {
            return nil
        }

        var request = URLRequest(url: urlWithQueryParams, withTracingId: true)

        // Set headers
        additionalHeaders?.forEach {
            request.setValue($0.value, forHTTPHeaderField: $0.key)
        }

        return request
    }
}
