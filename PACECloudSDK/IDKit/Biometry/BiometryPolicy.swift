//
//  BiometryPolicy.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation
import LocalAuthentication

public extension IDKit {
    struct BiometryPolicy {
        let laContext: LAContext

        var isBiometryAvailable: Bool {
            var authError: NSError?
            let isBiometryAvailable = laContext.canEvaluatePolicy(laPolicy, error: &authError)
            return isBiometryAvailable
        }

        var canEvaluatePolicy: Bool {
            var authError: NSError?
            return laContext.canEvaluatePolicy(laPolicy, error: &authError)
        }

        private var laPolicy: LAPolicy {
            .deviceOwnerAuthentication
        }

        init() {
            laContext = LAContext()
        }

        func evaluatePolicy(reasonText: String, completion: @escaping (Bool, Error?) -> Void) {
            laContext.evaluatePolicy(laPolicy, localizedReason: reasonText, reply: completion)
        }
    }
}

public extension IDKit.BiometryPolicy {
    static func generateTOTP(with totpData: Data, timeIntervalSince1970: TimeInterval) -> String? {
        guard let biometryTOTPData = try? JSONDecoder().decode(IDKit.BiometryTOTPData.self, from: totpData),
              let secretData = biometryTOTPData.secret.base32DecodedData, !secretData.isEmpty else { return nil }

        let algorithm: OneTimePassword.Generator.Algorithm

        switch biometryTOTPData.algorithm {
        case PCUserDeviceTOTP.PCUserAlgorithm.sha1.rawValue:
            algorithm = .sha1

        case PCUserDeviceTOTP.PCUserAlgorithm.sha256.rawValue:
            algorithm = .sha256

        case PCUserDeviceTOTP.PCUserAlgorithm.sha512.rawValue:
            algorithm = .sha512

        default:
            algorithm = .sha1
        }

        guard let generator = OneTimePassword.Generator(factor: .timer(period: biometryTOTPData.period),
                                                        secret: secretData,
                                                        algorithm: algorithm,
                                                        digits: biometryTOTPData.digits)
        else {
            return nil
        }

        let token = OneTimePassword.Token(name: "TOTP", issuer: "PACE", generator: generator)
        let time = Date(timeIntervalSince1970: timeIntervalSince1970)

        do {
            let passwordAtTime = try token.generator.password(at: time)
            return passwordAtTime
        } catch {
            return nil
        }
    }
}

extension IDKit.BiometryPolicy {
    static func retrieveMasterKey() -> String { // swiftlint:disable:this inclusive_language
        // We are appending a device id, because the Keychain is
        // persisted outside of the app's sandbox, therefore
        // we cannot guarantee that it will be deleted, when
        // the app is deleted.
        // However, to ensure that the secret is only ever available in
        // the current app, the device id, which is generated per
        // app install, will be appended to the given key.

        return "\(PACECloudSDK.DeviceInformation.id)_payment-authorize"
    }
}
