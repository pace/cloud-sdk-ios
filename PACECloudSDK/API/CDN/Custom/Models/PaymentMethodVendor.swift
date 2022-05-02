//
//  PaymentMethodVendor.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

public typealias PaymentMethodVendors = [PaymentMethodVendor]

public struct PaymentMethodVendor {
    public let id: String?
    public let slug: String?
    public let name: String?
    public let logo: PaymentMethodVendorLogo?
    public let paymentMethodKindId: String?

    init(from response: PaymentMethodVendorResponse) {
        self.id = response.id
        self.slug = response.slug
        self.name = response.name
        self.paymentMethodKindId = response.paymentMethodKindId

        if let responseLogo = response.logo {
            self.logo = .init(from: responseLogo)
        } else {
            self.logo = nil
        }
    }
}

public struct PaymentMethodVendorLogo {
    public let href: String?
    public let variants: PaymentMethodVendorLogoVariants?

    init(from response: PaymentMethodVendorLogoResponse) {
        if let responseHref = response.href {
            self.href = String(responseHref.dropFirst(Constants.cdnPaymentMethodVendorIconsURLPrefix.count))
        } else {
            self.href = nil
        }

        if let responseVariants = response.variants {
            self.variants = .init(from: responseVariants)
        } else {
            self.variants = nil
        }
    }
}

public struct PaymentMethodVendorLogoVariants {
    public let dark: PaymentMethodVendorLogoVariant?

    init(from response: PaymentMethodVendorLogoVariantsResponse) {
        if let responseDark = response.dark {
            self.dark = .init(from: responseDark)
        } else {
            self.dark = nil
        }
    }
}

public struct PaymentMethodVendorLogoVariant {
    public let href: String?

    init(from response: PaymentMethodVendorLogoVariantResponse) {
        if let responseHref = response.href {
            self.href = String(responseHref.dropFirst(Constants.cdnPaymentMethodVendorIconsURLPrefix.count))
        } else {
            self.href = nil
        }
    }
}

struct PaymentMethodVendorResponse: Decodable {
    let id: String?
    let slug: String?
    let name: String?
    let logo: PaymentMethodVendorLogoResponse?
    let paymentMethodKindId: String?

    private enum CodingKeys: String, CodingKey {
        case id, slug, name, logo
        case paymentMethodKindId = "payment-method-kindId"
    }
}

struct PaymentMethodVendorLogoResponse: Decodable {
    let href: String?
    let variants: PaymentMethodVendorLogoVariantsResponse?
}

struct PaymentMethodVendorLogoVariantsResponse: Decodable {
    let dark: PaymentMethodVendorLogoVariantResponse?
}

struct PaymentMethodVendorLogoVariantResponse: Decodable {
    let href: String?
}
