//
//  PaymentMethodVendor.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

public struct PaymentMethodVendor: Decodable {
    public let id: String?
    public let slug: String?
    public let name: String?
    public let logo: PCPayPaymentMethod?
    public let paymentMethodKindId: String?

    private enum CodingKeys: String, CodingKey {
        case id, slug, name, logo
        case paymentMethodKindId = "payment-method-kindId"
    }
}

public struct PaymentMethodVendorLogo: Decodable {
    public let href: String?
    public let variants: PaymentMethodVendorLogoVariants?
}

public struct PaymentMethodVendorLogoVariants: Decodable {
    public let dark: PaymentMethodVendorLogoVariant?
}

public struct PaymentMethodVendorLogoVariant: Decodable {
    public let href: String?
}
