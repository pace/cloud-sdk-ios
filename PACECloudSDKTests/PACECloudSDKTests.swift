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
        let envs: [PACECloudSDK.Environment] = [.development, .sandbox, .production]

        envs.forEach { env in
            PACECloudSDK.shared.setup(with: .init(apiKey: "apiKey", clientId: "unit-test-dummy", geoDatabaseMode: .disabled, environment: env))
            XCTAssertNotEqual(Settings.shared.apiGateway, "")
            XCTAssertNotEqual(Settings.shared.poiApiHostUrl, "")
        }
    }

    func testCommonUrls() {
        PACECloudSDK.shared.setup(with: .init(apiKey: "apiKey", clientId: "unit-test-dummy", geoDatabaseMode: .disabled, environment: .development))
        XCTAssertEqual(PACECloudSDK.URL.paceID.absoluteString, "https://id.dev.pace.cloud")
        XCTAssertEqual(PACECloudSDK.URL.payment.absoluteString, "https://pay.dev.pace.cloud")
        XCTAssertEqual(PACECloudSDK.URL.transactions.absoluteString, "https://pay.dev.pace.cloud/transactions")

        PACECloudSDK.shared.setup(with: .init(apiKey: "apiKey", clientId: "unit-test-dummy", geoDatabaseMode: .disabled, environment: .sandbox))
        XCTAssertEqual(PACECloudSDK.URL.paceID.absoluteString, "https://id.sandbox.pace.cloud")
        XCTAssertEqual(PACECloudSDK.URL.payment.absoluteString, "https://pay.sandbox.pace.cloud")
        XCTAssertEqual(PACECloudSDK.URL.transactions.absoluteString, "https://pay.sandbox.pace.cloud/transactions")

        PACECloudSDK.shared.setup(with: .init(apiKey: "apiKey", clientId: "unit-test-dummy", geoDatabaseMode: .disabled, environment: .production))
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
        let keychain = PACECloudSDK.Keychain()

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

    func testKeychainBiometryDeletion() {
        let keychain = PACECloudSDK.Keychain()

        let biometryKey1 = "\(PACECloudSDK.DeviceInformation.id)_payment-authorize"
        let biometryValue1 = "stringValue"

        let biometryKey2 = "\(PACECloudSDK.DeviceInformation.id)_host_payment-authorize"
        let biometryValue2 = "data".data(using: .utf8)!

        let nonBiometryKey = "some_key"
        let nonBiometryValue = "some_value"

        keychain.set(biometryValue1, for: biometryKey1)
        keychain.set(biometryValue2, for: biometryKey2)
        keychain.set(nonBiometryValue, for: nonBiometryKey)

        let persistedStringValue = keychain.getString(for: biometryKey1)
        let persistedDataValue = keychain.getData(for: biometryKey2)

        XCTAssertEqual(biometryValue1, persistedStringValue)
        XCTAssertEqual(biometryValue2, persistedDataValue)

        keychain.deleteAllTOTPData()

        let missingStringValue = keychain.getString(for: biometryKey1)
        let missingDataValue = keychain.getData(for: biometryKey2)
        let nonMissingValue = keychain.getString(for: nonBiometryKey)

        XCTAssertNil(missingStringValue)
        XCTAssertNil(missingDataValue)
        XCTAssertNotNil(nonMissingValue)
    }

    func testRandomHexString() {
        let hex = String.randomHex(length: 8)
        XCTAssertEqual(hex?.count, 8)

        let emptyHex1 = String.randomHex(length: -4)
        XCTAssertNil(emptyHex1)

        let emptyHex2 = String.randomHex(length: 0)
        XCTAssertNil(emptyHex2)

        let bigHex = String.randomHex(length: 50)
        XCTAssertEqual(bigHex?.count, 50)
    }
}
