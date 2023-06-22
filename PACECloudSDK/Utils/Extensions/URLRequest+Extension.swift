//
//  URLRequest+Extension.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

extension URLRequest {
    init(url: URL, withTracingId: Bool) {
        self.init(url: url)
        guard withTracingId else { return }
        self.setValue(Constants.Tracing.identifier, forHTTPHeaderField: Constants.Tracing.key)
    }

    static func defaultURLRequest(url: URL, withTracingId: Bool = false) -> URLRequest {
        var request: URLRequest = .init(url: url, withTracingId: withTracingId)
        request.setValue(Constants.userAgent, forHTTPHeaderField: HttpHeaderFields.userAgent.rawValue)
        return request
    }
}
