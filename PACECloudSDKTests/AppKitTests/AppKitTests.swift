//
//  AppKitTests.swift
//  AppKitTests
//
//  Created by PACE Telematics GmbH.
//

import XCTest
@testable import PACECloudSDK

class AppKitTests: XCTestCase {
    func testSendEventNotification() {
        let _ = expectation(forNotification: .appEventOccured, object: nil, handler: nil)
        AppKit.shared.sendEvent(.escapedForecourt(gasStationId: "appID"))
        waitForExpectations(timeout: 2, handler: nil)
    }
}
