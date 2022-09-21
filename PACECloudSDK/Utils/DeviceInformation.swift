//
//  DeviceInformation.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

struct DeviceInformation {
    static let deviceIdKey: String = "PACE-DeviceId"

    /**
     A 32 bytes long secure random hex string.
     The device id is not persisted across app installs.
    */
    static var id: String {
        if let deviceId = SDKUserDefaults.string(for: deviceIdKey, isUserSensitiveData: false) {
            return deviceId
        }

        var keyData = Data(count: 32)

        let result = keyData.withUnsafeMutableBytes {
            SecRandomCopyBytes(kSecRandomDefault, 32, $0.baseAddress!) // swiftlint:disable:this force_unwrapping
        }

        if result == errSecSuccess {
            let deviceId: String = keyData.hexEncodedString()
            SDKUserDefaults.set(deviceId, for: deviceIdKey, isUserSensitiveData: false)

            return deviceId
        } else {
            return "Missing device id"
        }
    }
}
