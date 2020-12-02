//
//  PaymentMethodsResponse.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

public extension API.Pay {
    struct PaymentMethodsResponse: Codable {
        public let data: [PaymentMethod]
    }

    struct PaymentMethod: Codable {
        public let id: String?
    }
}
