//
//  PACECloudSlimSDK+API.swift
//  PACECloudSlimSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

extension PACECloudSDK {
    func setupAPI() {
        API.POI.client.baseURL = Settings.shared.baseUrl(.poiApi)

        API.POI.client.defaultHeaders = [HttpHeaderFields.userAgent.rawValue: Bundle.paceCloudSDK.poiKitUserAgent,
                                         HttpHeaderFields.apiKey.rawValue: apiKey ?? "Missing API key"]
    }
}
