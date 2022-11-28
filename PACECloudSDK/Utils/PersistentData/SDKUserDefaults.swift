//
//  SDKUserDefaults.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

// swiftlint:disable user_defaults_wrapper

/// Wrapper for UserDefaults that scopes user specific data to the user id
class SDKUserDefaults {
    private static let shared = SDKUserDefaults()

    private let currentMigrationVersion: Int = 1

    private var previousMigrationVersion: Int {
        get { UserDefaults.standard.integer(forKey: Constants.userDefaultsMigrationVersionKey) }
        set { UserDefaults.standard.set(newValue, forKey: Constants.userDefaultsMigrationVersionKey) }
    }

    private var userId: String?

    private var userSuiteName: String? {
        return userId
    }

    private init() {}

    private func nonUserSuite(for key: String) -> UserDefaults? {
        let currentEnvironment = PACECloudSDK.shared.environment.rawValue
        let suffix = Constants.userDefaultsSuiteNameSuffix
        let suiteName = "\(currentEnvironment)_\(suffix)"
        guard let nonUserSuite = UserDefaults(suiteName: suiteName) else {
            SDKLogger.e("[SDKUserDefaults] Failed accessing user defaults global suite for key '\(key)'.")
            return nil
        }
        return nonUserSuite
    }

    private func userSuite(for key: String) -> UserDefaults? {
        guard let userSuiteName else { return nil }

        guard let userSuite = UserDefaults(suiteName: userSuiteName) else {
            SDKLogger.e("[SDKUserDefaults] Failed accessing user defaults user suite for key '\(key)'.")
            return nil
        }
        return userSuite
    }

    private func suite(for key: String, isUserSensitiveData: Bool) -> UserDefaults? {
        isUserSensitiveData ? userSuite(for: key) : nonUserSuite(for: key)
    }
}

extension SDKUserDefaults {
    static func string(for key: String, isUserSensitiveData: Bool) -> String? {
        shared.suite(for: key, isUserSensitiveData: isUserSensitiveData)?.string(forKey: key)
    }

    static func array(for key: String, isUserSensitiveData: Bool) -> [Any]? {
        shared.suite(for: key, isUserSensitiveData: isUserSensitiveData)?.array(forKey: key)
    }

    static func dictionary(for key: String, isUserSensitiveData: Bool) -> [String: Any]? {
        shared.suite(for: key, isUserSensitiveData: isUserSensitiveData)?.dictionary(forKey: key)
    }

    static func data(for key: String, isUserSensitiveData: Bool) -> Data? {
        shared.suite(for: key, isUserSensitiveData: isUserSensitiveData)?.data(forKey: key)
    }

    static func stringArray(for key: String, isUserSensitiveData: Bool) -> [String]? {
        shared.suite(for: key, isUserSensitiveData: isUserSensitiveData)?.stringArray(forKey: key)
    }

    static func integer(for key: String, isUserSensitiveData: Bool) -> Int {
        shared.suite(for: key, isUserSensitiveData: isUserSensitiveData)?.integer(forKey: key) ?? 0
    }

    static func float(for key: String, isUserSensitiveData: Bool) -> Float {
        shared.suite(for: key, isUserSensitiveData: isUserSensitiveData)?.float(forKey: key) ?? 0
    }

    static func double(for key: String, isUserSensitiveData: Bool) -> Double {
        shared.suite(for: key, isUserSensitiveData: isUserSensitiveData)?.double(forKey: key) ?? 0
    }

    static func bool(for key: String, isUserSensitiveData: Bool) -> Bool {
        shared.suite(for: key, isUserSensitiveData: isUserSensitiveData)?.bool(forKey: key) ?? false
    }

    static func value(for key: String, isUserSensitiveData: Bool) -> Any? {
        shared.suite(for: key, isUserSensitiveData: isUserSensitiveData)?.value(forKey: key)
    }
}

extension SDKUserDefaults {
    static func setUserId(_ userId: String) {
        shared.userId = userId
    }

    static func set(_ value: Any?, for key: String, isUserSensitiveData: Bool) {
        shared.suite(for: key, isUserSensitiveData: isUserSensitiveData)?.set(value, forKey: key)
    }

    static func removeObject(for key: String, isUserSensitiveData: Bool) {
        shared.suite(for: key, isUserSensitiveData: isUserSensitiveData)?.removeObject(forKey: key)
    }

    static func deleteUserScopedData() {
        guard let userSuiteName = shared.userSuiteName else {
            SDKLogger.e("[SDKUserDefaults] Failed removing user defaults user suite. User suite name couldn't be retrieved.")
            return
        }
        UserDefaults.standard.removePersistentDomain(forName: userSuiteName)
        UserDefaults.standard.removeSuite(named: userSuiteName)
        shared.userId = nil
    }
}

extension SDKUserDefaults {
    static func migrate() {
        shared.migrate()
    }

    static func migrateDataIfNeeded(key: String, isUserSensitiveData: Bool) {
        shared.migrateDataIfNeeded(key: key, isUserSensitiveData: isUserSensitiveData)
    }

    private func migrateDataIfNeeded(key: String, isUserSensitiveData: Bool) {
        guard let value = UserDefaults.standard.value(forKey: key) else { return }
        UserDefaults.standard.removeObject(forKey: key)
        suite(for: key, isUserSensitiveData: isUserSensitiveData)?.set(value, forKey: key)
    }

    private func migrate() {
        let previousMigrationVersion = previousMigrationVersion

        if previousMigrationVersion < 1 {
            #if !PACECloudWatchSDK
            // AppWebView CookieStorage
            migrateDataIfNeeded(key: AppKit.CookieStorage.cookiesKey, isUserSensitiveData: false)
            #endif

            // Device Id
            migrateDataIfNeeded(key: PACECloudSDK.DeviceInformation.deviceIdKey, isUserSensitiveData: false)
        }

        self.previousMigrationVersion = currentMigrationVersion
    }
}
