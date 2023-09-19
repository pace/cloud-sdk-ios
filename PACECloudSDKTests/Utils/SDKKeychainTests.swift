//
//  SDKKeychainTests.swift
//  PACECloudSDKTests
//
//  Created by PACE Telematics GmbH.
//

@testable import PACECloudSDK
import XCTest

final class SDKKeychainTests: XCTestCase {
    private let key = "key"
    private let value = "test"
    private let userId = "testUserId"

    override func setUpWithError() throws {
        reset()

        // Put setup code here. This method is called before the invocation of each test method in the class.
        PACECloudSDK.shared.setup(with: .init(apiKey: "",
                                              clientId: "unit-test-dummy",
                                              authenticationMode: .native,
                                              environment: .development,
                                              isRedirectSchemeCheckEnabled: false))
    }

    func reset() {
        SDKKeychain.deleteUserScopedData()
        SDKKeychain.delete(for: key, isUserSensitiveData: false)
        SDKKeychain.delete(for: key, isUserSensitiveData: true)
    }

    func testNonScopedData() {
        SDKKeychain.set(value, for: key, isUserSensitiveData: false)
        let value = SDKKeychain.string(for: key, isUserSensitiveData: false)
        XCTAssertEqual(value, value)
    }

    func testRemoveNonScopedData() {
        SDKKeychain.set(value, for: key, isUserSensitiveData: false)
        SDKKeychain.delete(for: key, isUserSensitiveData: false)
        let value = SDKKeychain.string(for: key, isUserSensitiveData: false)
        XCTAssertNil(value)
    }

    func testScopedDataWithoutSession() {
        SDKKeychain.set(value, for: key, isUserSensitiveData: true)
        let scopedValue = SDKKeychain.string(for: key, isUserSensitiveData: true)
        let nonScopedValue = SDKKeychain.string(for: key, isUserSensitiveData: false)
        XCTAssertNil(scopedValue)
        XCTAssertNil(nonScopedValue)
    }

    func testScopedData() {
        SDKKeychain.setUserId(userId)
        SDKKeychain.set(value, for: key, isUserSensitiveData: true)
        let value = SDKKeychain.string(for: key, isUserSensitiveData: true)
        XCTAssertEqual(value, value)
    }

    func testRemoveScopedData() {
        SDKKeychain.setUserId(userId)
        SDKKeychain.set(value, for: key, isUserSensitiveData: true)
        SDKKeychain.delete(for: key, isUserSensitiveData: true)
        let value = SDKKeychain.string(for: key, isUserSensitiveData: true)
        XCTAssertNil(value)
    }

    func testMigrateScopedData() {
        let keychain = PACECloudSDK.Keychain()
        keychain.set(value, for: key)

        SDKKeychain.setUserId(userId)
        SDKKeychain.migrateUserScopedStringIfNeeded(key: key)

        let removedValue = keychain.getString(for: key)
        let migratedValue = SDKKeychain.string(for: key, isUserSensitiveData: true)
        XCTAssertNil(removedValue)
        XCTAssertEqual(migratedValue, value)
    }
}
