//
//  CDNAPIClient+URLProtocol.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

public extension CDNAPIClient {
    private static var urlConfiguration: URLSessionConfiguration {
        let config = URLSessionConfiguration.default
        config.setCustomURLProtocolIfAvailable()
        return config
    }

    static var custom = CDNAPIClient(baseURL: CDNAPIClient.default.baseURL, configuration: urlConfiguration)
}
