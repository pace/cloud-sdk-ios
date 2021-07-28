//
//  PACECloudSDK+API.swift
//  PACECloudWatchSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

extension PACECloudSDK {
    func setupAPI() {
        API.Pay.client.baseURL = Settings.shared.baseUrl(.payApi)
        API.Fueling.client.baseURL = Settings.shared.baseUrl(.fuelingApi)
    }
}
