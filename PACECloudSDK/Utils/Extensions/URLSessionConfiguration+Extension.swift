//
//  URLSessionConfiguration+Extension.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

extension URLSessionConfiguration {
    func setCustomURLProtocolIfAvailable() {
        guard PACECloudSDK.shared.isCustomURLProtocolEnabled, let customURLProtocol = PACECloudSDK.shared.customURLProtocol else { return }
        protocolClasses = [customURLProtocol.classForCoder]
    }
}
