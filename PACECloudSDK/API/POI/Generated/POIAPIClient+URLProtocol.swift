//
// Generated by SwagGen
// https://github.com/pace/SwagGen
//

import Foundation

public extension POIAPIClient {
    private static var urlConfiguration: URLSessionConfiguration {
        let config = URLSessionConfiguration.default
        config.setCustomURLProtocolIfAvailable()
        return config
    }

    static var custom = POIAPIClient(baseURL: POIAPIClient.default.baseURL, configuration: urlConfiguration)
}

