//
//  Keychain.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation
import Security

public extension PACECloudSDK {
    class Keychain {
        private let lock = NSLock()

        public init() {}

        public func set(_ value: String, for key: String) {
            if let value = value.data(using: .utf8) {
                set(value, for: key)
            }
        }

        public func set(_ value: Data, for key: String) {
            lock.lock()

            // Delete existing key before saving a new one
            deleteWithoutLock(key)

            let query: [CFString: Any] = [kSecClass: kSecClassGenericPassword,
                                          kSecAttrAccount: key,
                                          kSecValueData: value,
                                          kSecAttrAccessible: kSecAttrAccessibleWhenUnlockedThisDeviceOnly]

            let resultCode = SecItemAdd(query as CFDictionary, nil)

            if resultCode != noErr && resultCode != errSecItemNotFound {
                let message = errorMessage(for: resultCode) ?? "No description"
                SDKLogger.e("[Keychain] Failed setting keychain data with error code \(resultCode) - \(message)")
            }

            lock.unlock()
        }

        public func getString(for key: String) -> String? {
            guard let data = getData(for: key), let stringValue = String(data: data, encoding: .utf8) else { return nil }
            return stringValue
        }

        public func getData(for key: String) -> Data? {
            lock.lock()
            defer { lock.unlock() }

            var query: [CFString: Any] = [kSecClass: kSecClassGenericPassword,
                                          kSecAttrAccount: key,
                                          kSecMatchLimit: kSecMatchLimitOne]
            query[kSecReturnData] = kCFBooleanTrue

            var result: AnyObject?

            let resultCode = withUnsafeMutablePointer(to: &result) {
                SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
            }

            if resultCode != noErr && resultCode != errSecItemNotFound {
                let message = errorMessage(for: resultCode) ?? "No description"
                SDKLogger.e("[Keychain] Failed retrieving data from keychain with error code \(resultCode) - \(message)")
            }

            return result as? Data
        }

        public func delete(_ key: String) {
            lock.lock()
            deleteWithoutLock(key)
            lock.unlock()
        }

        private func deleteWithoutLock(_ key: String) {
            let query: [CFString: Any] = [kSecClass: kSecClassGenericPassword,
                                          kSecAttrAccount: key]
            let resultCode = SecItemDelete(query as CFDictionary)

            if resultCode != noErr && resultCode != errSecItemNotFound {
                let message = errorMessage(for: resultCode) ?? "No description"
                SDKLogger.e("[Keychain] Failed deleting keychain data with error code \(resultCode) - \(message)")
            }
        }

        private func errorMessage(for resultCode: OSStatus) -> String? {
            if #available(iOS 11.3, *) {
                return SecCopyErrorMessageString(resultCode, nil) as String?
            } else {
                return nil
            }
        }
    }
}

extension PACECloudSDK.Keychain {
    private func deleteAllData(filterKeysBy condition: (String) -> Bool) {
        lock.lock()
        defer { lock.unlock() }

        var query: [CFString: Any] = [kSecClass: kSecClassGenericPassword, kSecMatchLimit: kSecMatchLimitAll]
        query[kSecReturnData] = kCFBooleanTrue
        query[kSecReturnAttributes] = kCFBooleanTrue

        var result: AnyObject?
        let resultCode = withUnsafeMutablePointer(to: &result) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }

        if resultCode != noErr && resultCode != errSecItemNotFound {
            let message = errorMessage(for: resultCode) ?? "No description"
            SDKLogger.e("[Keychain] Failed deleting keychain data with error code \(resultCode) - \(message)")
        }

        let matchingKeys = (result as? [[CFString: Any]])?
            .compactMap { $0[kSecAttrAccount] as? String }
            .filter { condition($0) }

        matchingKeys?.forEach(deleteWithoutLock)
    }

    func deleteAllTOTPData() {
        deleteAllData(filterKeysBy: { $0.hasSuffix("payment-authorize") })
    }

    func deleteAllUserScopedData(userId: String) {
        deleteAllData(filterKeysBy: { $0.hasPrefix(userId) })
    }
}
