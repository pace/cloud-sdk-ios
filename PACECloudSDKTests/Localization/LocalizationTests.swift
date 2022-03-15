//
//  LocalizationTests.swift
//  PACECloudSDKTests
//
//  Created by PACE Telematics GmbH.
//

import XCTest
@testable import PACECloudSDK

class LocalizationTests: XCTestCase {
    func testLocalizationSubclassing() {
        let subclass = LocalizationSubclassingTest()
        PACECloudSDK.shared.localizable = subclass
        XCTAssertEqual(PACECloudSDK.shared.localizable.commonClose, "test_commonClose")
        XCTAssertEqual(PACECloudSDK.shared.localizable.commonRetry, L10n.commonRetry)
    }

    func testLocalizationProtocol() {
        let protocolTest = LocalizationProtocolTest()
        PACECloudSDK.shared.localizable = protocolTest
        XCTAssertEqual(PACECloudSDK.shared.localizable.appkitSecureDataAuthenticationConfirmation, "test_appkitSecureDataAuthenticationConfirmation")
        XCTAssertEqual(PACECloudSDK.shared.localizable.commonClose, "test_commonClose")
        XCTAssertEqual(PACECloudSDK.shared.localizable.commonRetry, "test_commonRetry")
        XCTAssertEqual(PACECloudSDK.shared.localizable.errorGeneric, "test_errorGeneric")
        XCTAssertEqual(PACECloudSDK.shared.localizable.idkitBiometryAuthenticationConfirmation, "test_idkitBiometryAuthenticationConfirmation")
        XCTAssertEqual(PACECloudSDK.shared.localizable.loadingText, "test_loadingText")
    }
}

fileprivate class LocalizationSubclassingTest: PACECloudSDK.Localizable {
    override init() {
        super.init()
        commonClose = "test_commonClose"
    }
}

fileprivate class LocalizationProtocolTest: PACELocalizable {
    let appkitSecureDataAuthenticationConfirmation: String = "test_appkitSecureDataAuthenticationConfirmation"
    let commonClose: String = "test_commonClose"
    let commonRetry: String = "test_commonRetry"
    let errorGeneric: String = "test_errorGeneric"
    let idkitBiometryAuthenticationConfirmation: String = "test_idkitBiometryAuthenticationConfirmation"
    let loadingText: String = "test_loadingText"
}
