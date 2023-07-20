//
//  PACECloudSDK+API.swift
//  PACECloudWatchSDK
//
//  Created by PACE Telematics GmbH.
//

extension PACECloudSDK {
    func setupAPI() {
        API.POI.client.baseURL = Settings.shared.baseUrl(.poiApi)
        API.Pay.client.baseURL = Settings.shared.baseUrl(.payApi)
        API.Fueling.client.baseURL = Settings.shared.baseUrl(.fuelingApi)
        API.User.client.baseURL = Settings.shared.baseUrl(.userApi)
        API.CDN.client.baseURL = Settings.shared.baseUrl(.cdn)

        API.POI.client.defaultHeaders = [HttpHeaderFields.userAgent.rawValue: Constants.userAgent,
                                         HttpHeaderFields.apiKey.rawValue: apiKey ?? "Missing API key"]
        API.Pay.client.defaultHeaders = [HttpHeaderFields.userAgent.rawValue: Constants.userAgent]
        API.Fueling.client.defaultHeaders = [HttpHeaderFields.userAgent.rawValue: Constants.userAgent]
        API.User.client.defaultHeaders = [HttpHeaderFields.userAgent.rawValue: Constants.userAgent]
        API.CDN.client.defaultHeaders = [HttpHeaderFields.userAgent.rawValue: Constants.userAgent]
        API.Custom.client.defaultHeaders = [HttpHeaderFields.userAgent.rawValue: Constants.userAgent]
    }
}
