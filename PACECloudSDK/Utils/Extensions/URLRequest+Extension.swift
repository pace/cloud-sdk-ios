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
}
