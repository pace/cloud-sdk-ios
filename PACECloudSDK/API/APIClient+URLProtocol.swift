//
//  APIClient+URLProtocol.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

public extension APIClient {
    private static var urlConfiguration: URLSessionConfiguration {
        let config: URLSessionConfiguration = .default
        config.protocolClasses = [CustomURLProtocol.self]
        return config
    }

    static var custom = APIClient(baseURL: POIAPI.Server.main, configuration: urlConfiguration)
}
