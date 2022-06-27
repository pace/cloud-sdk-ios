//
//  PaymentMethodVendor.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

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
        self.href = buildRelativePaymentMethodVendorLogoURL(with: response.href)

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
        self.href = buildRelativePaymentMethodVendorLogoURL(with: response.href)
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

private func buildRelativePaymentMethodVendorLogoURL(with href: String?) -> String? {
    guard let href = href,
          let url = URL(string: href),
          let cdnBaseURL = URL(string: API.CDN.client.baseURL)
    else { return nil }

    if url.absoluteString.contains(Constants.paymentMethodVendorIconsCMSPrefix) {
        // Contains cms prefix
        return cdnBaseURL
            .appendingPathComponent(Constants.cdnPayPath)
            .appendingPathComponent(Constants.cdnPaymentMethodVendorsPath)
            .appendingPathComponent(url.lastPathComponent)
            .absoluteString
    } else if url.host != nil {
        // Absolute path
        return url.absoluteString
    } else if let relativeURL = URL(string: href, relativeTo: cdnBaseURL) {
        // Relative path
        return cdnBaseURL
            .appendingPathComponent(relativeURL.relativeString)
            .absoluteString
    } else {
        return nil
    }
}
