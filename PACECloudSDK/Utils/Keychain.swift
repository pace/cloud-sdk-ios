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
                SDKLogger.e("[Keychain] Failed setting keychain data with error code \(resultCode)")
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
                SDKLogger.e("[Keychain] Failed retrieving data from keychain with error code \(resultCode)")
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
                SDKLogger.e("[Keychain] Failed deleting keychain data with error code \(resultCode)")
            }
        }
    }
}

extension PACECloudSDK.Keychain {
    func deleteAllTOTPData() {
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
            SDKLogger.e("[Keychain] Failed deleting keychain data with error code \(resultCode)")
        }

        let matchingKeys = (result as? [[CFString: Any]])?
            .compactMap { $0[kSecAttrAccount] as? String }
            .filter { $0.hasSuffix("payment-authorize") }

        matchingKeys?.forEach(deleteWithoutLock)
    }
}
