//
//  APIClient+URLProtocol.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

public extension POIAPIClient {
    private static var urlConfiguration: URLSessionConfiguration {
        let config: URLSessionConfiguration = .default
        config.protocolClasses = [CustomURLProtocol.self]
        return config
    }

    static var custom = POIAPIClient(baseURL: POIAPIClient.default.baseURL, configuration: urlConfiguration)
}
