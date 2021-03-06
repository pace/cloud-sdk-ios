//
//  PACECloudSDK+API.swift
//  PACECloudSDK
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
        API.GeoJSON.client.baseURL = Settings.shared.baseUrl(.poiApi)
        API.Cms.client.baseURL = Settings.shared.baseUrl(.cms)

        API.POI.client.defaultHeaders = [HttpHeaderFields.userAgent.rawValue: Bundle.paceCloudSDK.poiKitUserAgent,
                                         HttpHeaderFields.apiKey.rawValue: apiKey ?? "Missing API key"]
        API.GeoJSON.client.defaultHeaders = [HttpHeaderFields.userAgent.rawValue: Bundle.paceCloudSDK.poiKitUserAgent,
                                             HttpHeaderFields.apiKey.rawValue: apiKey ?? "Missing API key"]
    }
}
