//
//  GeoJSONAPIClient+URLProtocol.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

public extension GeoJSONAPIClient {
    private static var urlConfiguration: URLSessionConfiguration {
        let config: URLSessionConfiguration = .default
        config.protocolClasses = [CustomURLProtocol.self]
        return config
    }

    static var custom = GeoJSONAPIClient(baseURL: GeoJSONAPIClient.default.baseURL, configuration: urlConfiguration)
}
