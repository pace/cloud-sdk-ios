//
//  PACECloudSDKTests.swift
//  PACECloudSDKTests
//
//  Created by PACE Telematics GmbH.
//

import XCTest
@testable import PACECloudSDK

class PACECloudSDKTests: XCTestCase {
    func testSettings() {
        let envs: [PACECloudSDK.Environment] = [.development, .sandbox, .stage, .production]

        envs.forEach { env in
            PACECloudSDK.shared.setup(with: .init(clientId: "", apiKey: "apiKey", environment: env))
            XCTAssertNotEqual(Settings.shared.apiGateway, "")
            XCTAssertNotEqual(Settings.shared.poiApiHostUrl, "")
            XCTAssertNotEqual(Settings.shared.osrmBaseUrl, "")
            XCTAssertNotEqual(Settings.shared.searchBaseUrl, "")
            XCTAssertNotEqual(Settings.shared.reverseGeocodeBaseUrl, "")
            XCTAssertNotEqual(Settings.shared.tileBaseUrl, "")
            XCTAssertNotEqual(Settings.shared.tilesApiUrl, "")
        }
    }
}
