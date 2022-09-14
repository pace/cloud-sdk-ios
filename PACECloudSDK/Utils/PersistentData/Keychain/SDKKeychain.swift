//
//  SDKKeychain.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

// swiftlint:disable user_defaults_wrapper keychain_wrapper

/// Wrapper for Keychain that scopes user specific data to the user id
class SDKKeychain {
    private static let shared = SDKKeychain()

    private let keychain = PACECloudSDK.Keychain()

    private let currentMigrationVersion: Int = 0

    private var previousMigrationVersion: Int {
        get { UserDefaults.standard.integer(forKey: Constants.keychainMigrationVersionKey) }
        set { UserDefaults.standard.set(newValue, forKey: Constants.keychainMigrationVersionKey) }
    }

    private var userId: String?

    private init() {}

    private func keychainKey(for key: String, isUserSensitiveData: Bool) -> String? {
        guard isUserSensitiveData else { return key }

        guard let userId else { return nil }
        return "\(userId)_\(key)"
    }
}

extension SDKKeychain {
    static func string(for key: String, isUserSensitiveData: Bool) -> String? {
        guard let keychainKey = shared.keychainKey(for: key, isUserSensitiveData: isUserSensitiveData) else { return nil }
        return shared.keychain.getString(for: keychainKey)
    }

    static func data(for key: String, isUserSensitiveData: Bool) -> Data? {
        guard let keychainKey = shared.keychainKey(for: key, isUserSensitiveData: isUserSensitiveData) else { return nil }
        return shared.keychain.getData(for: keychainKey)
    }
}

extension SDKKeychain {
    static func setUserId(_ userId: String) {
        shared.userId = userId
    }

    static func set(_ value: String, for key: String, isUserSensitiveData: Bool) {
        shared.set(value, for: key, isUserSensitiveData: isUserSensitiveData)
    }

    static func set(_ value: Data, for key: String, isUserSensitiveData: Bool) {
        shared.set(value, for: key, isUserSensitiveData: isUserSensitiveData)
    }

    static func delete(for key: String, isUserSensitiveData: Bool) {
        guard let keychainKey = shared.keychainKey(for: key, isUserSensitiveData: isUserSensitiveData) else { return }
        shared.keychain.delete(keychainKey)
    }

    static func deleteAllTOTPData() {
        shared.keychain.deleteAllTOTPData()
    }

    static func deleteUserScopedData() {
        guard let userId = shared.userId else {
            SDKLogger.e("[SDKKeychain] Failed removing user scoped data from keychain. User id couldn't be retrieved.")
            return
        }
        shared.keychain.deleteAllUserScopedData(userId: userId)
        shared.userId = nil
    }

    private func set(_ value: String, for key: String, isUserSensitiveData: Bool) {
        guard let keychainKey = keychainKey(for: key, isUserSensitiveData: isUserSensitiveData) else { return }
        keychain.set(value, for: keychainKey)
    }

    private func set(_ value: Data, for key: String, isUserSensitiveData: Bool) {
        guard let keychainKey = keychainKey(for: key, isUserSensitiveData: isUserSensitiveData) else { return }
        keychain.set(value, for: keychainKey)
    }
}

extension SDKKeychain {
    static func migrate() {
        shared.migrate()
    }

    static func migrateUserScopedStringIfNeeded(key: String) {
        shared.migrateUserScopedStringIfNeeded(key: key)
    }

    static func migrateUserScopedDataIfNeeded(key: String) {
        shared.migrateUserScopedDataIfNeeded(key: key)
    }

    private func migrateUserScopedStringIfNeeded(key: String) {
        guard let value = keychain.getString(for: key) else { return }
        keychain.delete(key)
        set(value, for: key, isUserSensitiveData: true)
    }

    private func migrateUserScopedDataIfNeeded(key: String) {
        guard let value = keychain.getData(for: key) else { return }
        keychain.delete(key)
        set(value, for: key, isUserSensitiveData: true)
    }

    private func migrate() {}
}
