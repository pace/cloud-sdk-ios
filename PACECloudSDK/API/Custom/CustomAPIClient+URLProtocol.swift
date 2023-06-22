//
//  CustomAPIClient+URLProtocol.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

public extension CustomAPIClient {
    private static var urlConfiguration: URLSessionConfiguration {
        let config = URLSessionConfiguration.default
        config.setCustomURLProtocolIfAvailable()
        return config
    }

    static var custom = CustomAPIClient(configuration: urlConfiguration)
}
