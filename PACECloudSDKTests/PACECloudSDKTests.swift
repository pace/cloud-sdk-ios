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

    func testDomainACL() {
        let domainACL = [
            "fuel.site",
            "pace.cloud",
            "pay.pace"
        ]

        let host1 = "hem.fuel.site"
        let host2 = "id.pace.cloud"
        let host3 = "id.pace.cloud.stars"
        let host4 = "pay.pace.id"

        XCTAssertTrue(domainACL.contains(where: { host1.hasSuffix($0) }))
        XCTAssertTrue(domainACL.contains(where: { host2.hasSuffix($0) }))
        XCTAssertFalse(domainACL.contains(where: { host3.hasSuffix($0) }))
        XCTAssertFalse(domainACL.contains(where: { host4.hasSuffix($0) }))
    }

    func testKeychain() {
        let keychain = Keychain()

        let stringKey = "stringKey"
        let stringValue = "stringValue"

        let dataKey = "dataKey"
        let dataValue = "data".data(using: .utf8)!

        keychain.set(stringValue, for: stringKey)
        keychain.set(dataValue, for: dataKey)

        let persistedStringValue = keychain.getString(for: stringKey)
        let persistedDataValue = keychain.getData(for: dataKey)

        XCTAssertEqual(stringValue, persistedStringValue)
        XCTAssertEqual(dataValue, persistedDataValue)

        keychain.delete(stringKey)
        keychain.delete(dataKey)

        let missingStringValue = keychain.getString(for: stringKey)
        let missingDataValue = keychain.getData(for: dataKey)

        XCTAssertNil(missingStringValue)
        XCTAssertNil(missingDataValue)
    }
}
