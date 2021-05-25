//
//  CmsAPIClient+URLProtocol.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

public extension CmsAPIClient {
    private static var urlConfiguration: URLSessionConfiguration {
        let config = URLSessionConfiguration.default
        config.setCustomURLProtocolIfAvailable()
        return config
    }

    static var custom = CmsAPIClient(baseURL: CmsAPIClient.default.baseURL, configuration: urlConfiguration)
}
