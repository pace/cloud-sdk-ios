//
//  URNTests.swift
//  AppKitTests
//
//  Created by PACE Telematics GmbH.
//

import XCTest
@testable import PACECloudSDK

class URNTests: XCTestCase {
    private let appUrl = "https://pace.car"
    private let validReference = "prn:poi:gas-stations:f582e5b4-5424-453f-9d7d-8c106b8360d3"
    private let appManager = AppManager()

    func testValidReference() {
        let url = appManager.buildAppUrl(with: appUrl, for: validReference)
        XCTAssertNotNil(url)
        XCTAssertEqual("\(appUrl)?r=\(validReference)", url)
    }

    func testCaseSensitivity() {
        let url = appManager.buildAppUrl(with: appUrl, for: validReference.uppercased())
        XCTAssertNotNil(url)
        XCTAssertEqual("\(appUrl)?r=\(validReference.uppercased())", url)
    }

    func testInvalidReferences() {
        let url1 = appManager.buildAppUrl(with: appUrl, for: "")
        let url2 = appManager.buildAppUrl(with: appUrl, for: "prn:")
        let url3 = appManager.buildAppUrl(with: appUrl, for: "123456789")

        XCTAssertNil(url1)
        XCTAssertNil(url2)
        XCTAssertNil(url3)
    }
}
