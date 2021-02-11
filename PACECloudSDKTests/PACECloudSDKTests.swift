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
            PACECloudSDK.shared.setup(with: .init(apiKey: "apiKey", environment: env))
            XCTAssertNotEqual(Settings.shared.apiGateway, "")
            XCTAssertNotEqual(Settings.shared.poiApiHostUrl, "")
            XCTAssertNotEqual(Settings.shared.osrmBaseUrl, "")
            XCTAssertNotEqual(Settings.shared.searchBaseUrl, "")
            XCTAssertNotEqual(Settings.shared.reverseGeocodeBaseUrl, "")
            XCTAssertNotEqual(Settings.shared.tileBaseUrl, "")
            XCTAssertNotEqual(Settings.shared.tilesApiUrl, "")
        }
    }

    func testCommonUrls() {
        PACECloudSDK.shared.setup(with: .init(apiKey: "apiKey", environment: .development))
        XCTAssertEqual(PACECloudSDK.URL.paceID.absoluteString, "https://id.dev.pace.cloud")
        XCTAssertEqual(PACECloudSDK.URL.payment.absoluteString, "https://pay.dev.pace.cloud")
        XCTAssertEqual(PACECloudSDK.URL.transactions.absoluteString, "https://pay.dev.pace.cloud/transactions")

        PACECloudSDK.shared.setup(with: .init(apiKey: "apiKey", environment: .sandbox))
        XCTAssertEqual(PACECloudSDK.URL.paceID.absoluteString, "https://id.sandbox.pace.cloud")
        XCTAssertEqual(PACECloudSDK.URL.payment.absoluteString, "https://pay.sandbox.pace.cloud")
        XCTAssertEqual(PACECloudSDK.URL.transactions.absoluteString, "https://pay.sandbox.pace.cloud/transactions")

        PACECloudSDK.shared.setup(with: .init(apiKey: "apiKey", environment: .stage))
        XCTAssertEqual(PACECloudSDK.URL.paceID.absoluteString, "https://id.stage.pace.cloud")
        XCTAssertEqual(PACECloudSDK.URL.payment.absoluteString, "https://pay.stage.pace.cloud")
        XCTAssertEqual(PACECloudSDK.URL.transactions.absoluteString, "https://pay.stage.pace.cloud/transactions")

        PACECloudSDK.shared.setup(with: .init(apiKey: "apiKey", environment: .production))
        XCTAssertEqual(PACECloudSDK.URL.paceID.absoluteString, "https://id.pace.cloud")
        XCTAssertEqual(PACECloudSDK.URL.payment.absoluteString, "https://pay.pace.cloud")
        XCTAssertEqual(PACECloudSDK.URL.transactions.absoluteString, "https://pay.pace.cloud/transactions")
    }
}
