//
//  SDKUserDefaultsTests.swift
//  PACECloudSDKTests
//
//  Created by PACE Telematics GmbH.
//

@testable import PACECloudSDK
import XCTest

final class SDKUserDefaultsTests: XCTestCase {
    private let key = "key"
    private let value = "test"
    private let userId = "testUserId"

    override func setUpWithError() throws {
        reset()

        // Put setup code here. This method is called before the invocation of each test method in the class.
        PACECloudSDK.shared.setup(with: .init(apiKey: "",
                                              authenticationMode: .native,
                                              environment: .development,
                                              isRedirectSchemeCheckEnabled: false))
    }

    func reset() {
        SDKUserDefaults.deleteUserScopedData()
        SDKUserDefaults.removeObject(for: key, isUserSensitiveData: false)
        SDKUserDefaults.removeObject(for: key, isUserSensitiveData: true)
    }

    func testNonScopedData() {
        SDKUserDefaults.set(value, for: key, isUserSensitiveData: false)
        let value = SDKUserDefaults.string(for: key, isUserSensitiveData: false)
        XCTAssertEqual(value, value)
    }

    func testRemoveNonScopedData() {
        SDKUserDefaults.set(value, for: key, isUserSensitiveData: false)
        SDKUserDefaults.removeObject(for: key, isUserSensitiveData: false)
        let value = SDKUserDefaults.string(for: key, isUserSensitiveData: false)
        XCTAssertNil(value)
    }

    func testMigrateNonScopedData() {
        UserDefaults.standard.set(value, forKey: key)
        SDKUserDefaults.migrateDataIfNeeded(key: key, isUserSensitiveData: false)
        let removedValue = UserDefaults.standard.string(forKey: key)
        let migratedValue = SDKUserDefaults.string(for: key, isUserSensitiveData: false)
        XCTAssertNil(removedValue)
        XCTAssertEqual(migratedValue, value)
    }

    func testScopedDataWithoutSession() {
        SDKUserDefaults.set(value, for: key, isUserSensitiveData: true)
        let scopedValue = SDKUserDefaults.string(for: key, isUserSensitiveData: true)
        let nonScopedValue = SDKUserDefaults.string(for: key, isUserSensitiveData: false)
        XCTAssertNil(scopedValue)
        XCTAssertNil(nonScopedValue)
    }

    func testScopedData() {
        SDKUserDefaults.setUserId(userId)
        SDKUserDefaults.set(value, for: key, isUserSensitiveData: true)
        let value = SDKUserDefaults.string(for: key, isUserSensitiveData: true)
        XCTAssertEqual(value, value)
    }

    func testRemoveScopedData() {
        SDKUserDefaults.setUserId(userId)
        SDKUserDefaults.set(value, for: key, isUserSensitiveData: true)
        SDKUserDefaults.removeObject(for: key, isUserSensitiveData: true)
        let value = SDKUserDefaults.string(for: key, isUserSensitiveData: true)
        XCTAssertNil(value)
    }

    func testMigrateScopedData() {
        SDKUserDefaults.setUserId(userId)
        UserDefaults.standard.set(value, forKey: key)
        SDKUserDefaults.migrateDataIfNeeded(key: key, isUserSensitiveData: true)
        let removedValue = UserDefaults.standard.string(forKey: key)
        let migratedValue = SDKUserDefaults.string(for: key, isUserSensitiveData: true)
        XCTAssertNil(removedValue)
        XCTAssertEqual(migratedValue, value)
    }

    func testDeleteUserSuite() {
        SDKUserDefaults.setUserId(userId)
        SDKUserDefaults.set(value, for: key, isUserSensitiveData: true)
        let setValue = SDKUserDefaults.string(for: key, isUserSensitiveData: true)
        XCTAssertEqual(setValue, value)
        SDKUserDefaults.deleteUserScopedData()
        let deletedValue = SDKUserDefaults.string(for: key, isUserSensitiveData: true)
        XCTAssertNil(deletedValue)
    }
}
