//
//  PaymentMethodVendorIcon.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

public typealias PaymentMethodVendorIcons = [PaymentMethodVendorIcon]

public struct PaymentMethodVendorIcon: Codable {
    public let vendorId: String
    public let paymentMethodKindId: String
    public let slug: String
    public let iconLight: Data
    public let iconDark: Data?
}
