//
//  Keychain+Slim.swift
//  PACECloudSlimSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

public extension PACECloudSDK {
    class Keychain {
        public func getData(for key: String) -> Data? { nil }
    }
}

class SDKKeychain {
    static func setUserId(_ userId: String) {}
    static func deleteUserScopedData() {}
    static func data(for key: String, isUserSensitiveData: Bool) -> Data? { nil }
    static func migrate() {}
}
