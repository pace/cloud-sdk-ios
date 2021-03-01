//
//  GeoJSONAPIClient+URLProtocol.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

public extension GeoJSONAPIClient {
    private static var urlConfiguration: URLSessionConfiguration {
        .default
    }

    static var custom = GeoJSONAPIClient(baseURL: GeoJSONAPIClient.default.baseURL, configuration: urlConfiguration)
}
