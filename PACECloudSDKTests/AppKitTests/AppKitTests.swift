//
//  AppKitTests.swift
//  AppKitTests
//
//  Created by PACE Telematics GmbH.
//

import XCTest
@testable import PACECloudSDK

class AppKitTests: XCTestCase {
    func testAppSettings() {
        AppKit.shared.setup(config: .init(clientId: "", environment: .development))
        XCTAssertNotEqual(AppSettings.shared.cloudGateway, "")
        XCTAssertNotEqual(AppSettings.shared.idGateway, "")
    }

    func testSendEventNotification() {
        let _ = expectation(forNotification: .appEventOccured, object: nil, handler: nil)
        AppKit.shared.sendEvent(.escapedForecourt(uuid: "appID"))
        waitForExpectations(timeout: 2, handler: nil)
    }
}
