//
//  URLRequestBuilder.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

struct URLRequestBuilder {

    static func buildRequestWithEtag(with urlString: String, additionalHeaders: [String: String]?) -> URLRequest? {
        guard let url = URL(string: urlString) else {
            return nil
        }

        var request = URLRequest(url: url)

        //Set headers
        additionalHeaders?.forEach {
            request.setValue($0.value, forHTTPHeaderField: $0.key)
        }

        return request
    }
}
