//
//  PINValidityTests.swift
//  PACECloudSDKTests
//
//  Created by PACE Telematics GmbH.
//

import XCTest
@testable import PACECloudSDK

class PINValidityTests: XCTestCase {
    override func setUpWithError() throws {
        PACECloudSDK.shared.setup(with: .init(apiKey: "apiKey", clientId: "unit-test-dummy", geoDatabaseMode: .disabled, environment: .development))
    }

    func testValidPINs() {
        ["1235", "9875", "1012", "1123", "4378"].forEach { pin in
            XCTAssertTrue(IDKit.isPINValid(pin: pin))
        }
    }

    func testInvalidPINs() {
        ["1234", "9012", "0987", "6543", "1122", "1111", "123", "456123"].forEach { pin in
            XCTAssertFalse(IDKit.isPINValid(pin: pin))
        }
    }
}
