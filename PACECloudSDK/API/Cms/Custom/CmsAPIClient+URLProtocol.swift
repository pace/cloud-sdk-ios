//
//  CmsAPIClient+URLProtocol.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

public extension CmsAPIClient {
    private static var urlConfiguration: URLSessionConfiguration {
        .default
    }

    static var custom = CmsAPIClient(baseURL: CmsAPIClient.default.baseURL, configuration: urlConfiguration)
}
