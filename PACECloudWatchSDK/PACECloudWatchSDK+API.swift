//
//  PACECloudSDK+API.swift
//  PACECloudWatchSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

extension PACECloudSDK {
    func setupAPI() {
        API.POI.client.baseURL = Settings.shared.baseUrl(.poiApi)
        API.Pay.client.baseURL = Settings.shared.baseUrl(.payApi)
        API.Fueling.client.baseURL = Settings.shared.baseUrl(.fuelingApi)
        API.User.client.baseURL = Settings.shared.baseUrl(.userApi)

        API.POI.client.defaultHeaders = [HttpHeaderFields.userAgent.rawValue: Bundle.paceCloudSDK.poiKitUserAgent,
                                         HttpHeaderFields.apiKey.rawValue: apiKey ?? "Missing API key"]
    }
}
