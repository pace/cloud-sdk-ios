//
//  ApplePay.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation
import PassKit

public extension AppKit {
    struct ApplePayRequest: Codable {
        public let currencyCode: String
        public let countryCode: String
        public let merchantCapabilities: [String]
        public let supportedNetworks: [String]
        public let shippingType: String
        public let requiredBillingContactFields: [String]
        public let requiredShippingContactFields: [String]
        public let total: ApplePayRequestTotal
    }

    struct ApplePayRequestTotal: Codable {
        public let label: String
        public let amount: String
        public let type: String
    }
}
