//
//  DeviceInformation.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

#if PACECloudWatchSDK
import WatchKit
#else
import UIKit
#endif

public extension PACECloudSDK {
    struct DeviceInformation {
        public static let deviceIdKey: String = "PACE-DeviceId"

        /**
         A 32 bytes long secure random hex string.
         The device id is not persisted across app installs.
         */
        public static var id: String {
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

        public static var deviceVersion: String {
            #if PACECloudWatchSDK
            WKInterfaceDevice.current().systemVersion
            #else
            UIDevice.current.systemVersion
            #endif
        }

        public static var osName: String {
            #if PACECloudWatchSDK
            return "watchOS"
            #else
            return "iOS"
            #endif
        }
    }
}
