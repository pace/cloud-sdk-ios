//
//  Pay.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

public extension API {
    struct Pay {
        public static let client: PayAPIClient = .default
    }
}

public extension API.Pay {
    enum PayEnvironmentBaseUrl: String {
        case production = "https://api.pace.cloud/pay"
        case stage = "https://api.stage.pace.cloud/pay"
        case sandbox = "https://api.sandbox.pace.cloud/pay"
        case development = "https://api.dev.pace.cloud/pay"
    }
}
