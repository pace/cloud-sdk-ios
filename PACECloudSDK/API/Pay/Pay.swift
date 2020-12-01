//
//  Pay.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

public extension API {
    struct Pay {}
}

public extension API.Pay {
    enum PayEnvironmentBaseUrl: String {
        case production = "https://api.pace.cloud/pay/beta"
        case stage = "https://api.stage.pace.cloud/pay/beta"
        case sandbox = "https://api.sandbox.pace.cloud/pay/beta"
        case development = "https://api.dev.pace.cloud/pay/beta"
    }
}
