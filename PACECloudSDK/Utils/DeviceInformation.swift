//
//  DeviceInformation.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

struct DeviceInformation {
    /**
     A 32 bytes long secure random hex string.
     The device id is not persisted across app installs.
    */
    static var id: String {
        let deviceIdKey: String = "PACE-DeviceId"

        if let deviceId = UserDefaults.standard.string(forKey: deviceIdKey) {
            return deviceId
        }

        var keyData = Data(count: 32)

        let result = keyData.withUnsafeMutableBytes {
            SecRandomCopyBytes(kSecRandomDefault, 32, $0.baseAddress!)
        }

        if result == errSecSuccess {
            let deviceId: String = keyData.hexEncodedString()
            UserDefaults.standard.set(deviceId, forKey: deviceIdKey)

            return deviceId
        } else {
            return "Missing device id"
        }
    }
}
