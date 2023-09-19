//
//  CDNAPITests.swift
//  PACECloudSDKTests
//
//  Created by PACE Telematics GmbH.
//

import XCTest
@testable import PACECloudSDK

class CDNAPITests: XCTestCase {
    private let vendorLogoLightURLString = "https://cdn.dev.pace.cloud/pay/payment-method-vendors/test.png"
    private let vendorLogoDarkURLString = "https://cdn.dev.pace.cloud/pay/payment-method-vendors/test_dark.png"

    override func setUp() {
        PACECloudSDK.shared.setup(with: .init(apiKey: "apiKey",
                                              clientId: "unit-test-dummy",
                                              environment: .development,
                                              isRedirectSchemeCheckEnabled: false,
                                              geoAppsScope: "pace-drive-ios-min"))
    }

    func testPaymentMethodVendorLogoURLCMSPrefix() {
        let logo = PaymentMethodVendorLogo(from: .init(href: "/cms/images/payment-method-vendors/test.png", variants: .init(dark: .init(href: "/cms/images/payment-method-vendors/test_dark.png"))))
        XCTAssertEqual(logo.href, vendorLogoLightURLString)
        XCTAssertEqual(logo.variants?.dark?.href, vendorLogoDarkURLString)
    }

    func testPaymentMethodVendorLogoURLRelativePath() {
        let logo = PaymentMethodVendorLogo(from: .init(href: "/pay/payment-method-vendors/test.png", variants: .init(dark: .init(href: "/pay/payment-method-vendors/test_dark.png"))))
        XCTAssertEqual(logo.href, vendorLogoLightURLString)
        XCTAssertEqual(logo.variants?.dark?.href, vendorLogoDarkURLString)
    }

    func testPaymentMethodVendorLogoURLAbsolutePath() {
        let logo = PaymentMethodVendorLogo(from: .init(href: "https://cdn.dev.pace.cloud/pay/payment-method-vendors/test.png", variants: .init(dark: .init(href: "https://cdn.dev.pace.cloud/pay/payment-method-vendors/test_dark.png"))))
        XCTAssertEqual(logo.href, vendorLogoLightURLString)
        XCTAssertEqual(logo.variants?.dark?.href, vendorLogoDarkURLString)
    }

    func testPaymentMethodVendorLogoURLInvalidPath() {
        let logo = PaymentMethodVendorLogo(from: .init(href: "", variants: .init(dark: .init(href: ""))))
        XCTAssertNil(logo.href)
        XCTAssertNil(logo.variants?.dark?.href)
    }
}
