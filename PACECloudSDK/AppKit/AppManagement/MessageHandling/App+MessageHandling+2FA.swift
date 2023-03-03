//
//  App+2FA.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import WebKit

extension App {
    func retrieveKey(for key: String, host: String) -> String {
        // We are appending a device id, because the Keychain is
        // persisted outside of the app's sandbox, therefore
        // we cannot guarantee that it will be deleted, when
        // the app is deleted.
        // However, to ensure that the secret is only ever available in
        // the current app, the device id, which is generated per
        // app install, will be appended to the given key.

        return "\(PACECloudSDK.DeviceInformation.id)_\(host)_\(key)"
    }

    func handleGetBiometricStatus(completion: @escaping (API.Communication.GetBiometricStatusResult) -> Void) {
        let isBiometryAvailable = IDKit.BiometryPolicy().isBiometryAvailable
        completion(.init(.init(response: .init(biometryAvailable: isBiometryAvailable))))
    }

    func handleSetTOTP(with request: API.Communication.SetTOTPRequest, requestUrl: URL?, completion: @escaping (API.Communication.SetTOTPResult) -> Void) {
        guard let host = requestUrl?.host else {
            AppKit.shared.notifyDidFail(with: .badRequest)
            completion(.init(.init(statusCode: .badRequest, response: .init(message: "The request url couldn't be retrieved."))))
            return
        }

        let biometryPolicy = IDKit.BiometryPolicy()
        let reasonText = PACECloudSDK.shared.localizable.appkitSecureDataAuthenticationConfirmation

        guard biometryPolicy.canEvaluatePolicy else {
            completion(.init(.init(statusCode: .methodNotAllowed, response: .init(message: "Couldn't evaluate the client's biometry policy."))))
            return
        }

        biometryPolicy.evaluatePolicy(reasonText: reasonText) { [weak self] success, error in
            guard error == nil, success, let unwrappedSelf = self else {
                completion(.init(.init(statusCode: .unauthorized,
                                       response: .init(message: "The authorization failed while evaluating the biometry policy. - \(String(describing: error))"))))
                return
            }

            do {
                let data = try JSONEncoder().encode(request)
                let secretKey: String = unwrappedSelf.retrieveKey(for: request.key, host: host)
                unwrappedSelf.setAppTOTPData(to: data, for: secretKey, host: host)
            } catch {
                completion(.init(.init(statusCode: .internalServerError, response: .init(message: "\(error)"))))
            }

            completion(.init(.init()))
        }
    }

    func handleGetTOTP(with request: API.Communication.GetTOTPRequest, requestUrl: URL?, completion: @escaping (API.Communication.GetTOTPResult) -> Void) {
        guard let host = requestUrl?.host else {
            AppKit.shared.notifyDidFail(with: .badRequest)
            completion(.init(.init(statusCode: .badRequest, response: .init(message: "The request url couldn't be retrieved."))))
            return
        }

        let secretKey: String = retrieveKey(for: request.key, host: host)

        guard let totpData = appTOTPData(for: secretKey) ?? masterTOTPData(host: host) else {
            completion(.init(.init(statusCode: .notFound, response: .init(message: "Couldn't retrieve totp data."))))
            return
        }

        let biometryPolicy = IDKit.BiometryPolicy()
        let reasonText = PACECloudSDK.shared.localizable.appkitSecureDataAuthenticationConfirmation

        guard biometryPolicy.canEvaluatePolicy else {
            completion(.init(.init(statusCode: .methodNotAllowed, response: .init(message: "Couldn't evaluate the client's biometry policy."))))
            return
        }

        biometryPolicy.evaluatePolicy(reasonText: reasonText) { success, error in
            guard error == nil, success else {
                completion(.init(.init(statusCode: .unauthorized,
                                       response: .init(message: "The authorization failed while evaluating the biometry policy. - \(String(describing: error))"))))
                return
            }

            guard let totp = IDKit.BiometryPolicy.generateTOTP(with: totpData, timeIntervalSince1970: request.serverTime) else {
                completion(.init(.init(statusCode: .internalServerError, response: .init(message: "Failed generating a device totp."))))
                return
            }

            let biometryMethod: AppKit.BiometryMethod

            switch biometryPolicy.laContext.biometryType {
            case .faceID:
                biometryMethod = .face

            case .touchID:
                biometryMethod = .fingerprint

            default:
                biometryMethod = .fingerprint
            }

            completion(.init(.init(response: .init(totp: totp, biometryMethod: biometryMethod.rawValue))))
        }
    }

    func handleSetSecureData(with request: API.Communication.SetSecureDataRequest, requestUrl: URL?, completion: @escaping (API.Communication.SetSecureDataResult) -> Void) {
        guard let host = requestUrl?.host else {
            AppKit.shared.notifyDidFail(with: .badRequest)
            completion(.init(.init(statusCode: .badRequest, response: .init(message: "The request url couldn't be retrieved."))))
            return
        }

        let key = retrieveKey(for: request.key, host: host)
        setSecureData(value: request.value, for: key)

        completion(.init(.init()))
    }

    func handleGetSecureData(with request: API.Communication.GetSecureDataRequest, requestUrl: URL?, completion: @escaping (API.Communication.GetSecureDataResult) -> Void) {
        guard let host = requestUrl?.host else {
            AppKit.shared.notifyDidFail(with: .badRequest)
            completion(.init(.init(statusCode: .badRequest, response: .init(message: "The request url couldn't be retrieved."))))
            return
        }

        let key = retrieveKey(for: request.key, host: host)

        guard let value = secureData(for: key) else {
            completion(.init(.init(statusCode: .notFound, response: .init(message: "Couldn't retrieve the secure data."))))
            return
        }

        let biometryPolicy = IDKit.BiometryPolicy()
        let reasonText = PACECloudSDK.shared.localizable.appkitSecureDataAuthenticationConfirmation

        guard biometryPolicy.canEvaluatePolicy else {
            completion(.init(.init(statusCode: .methodNotAllowed, response: .init(message: "Couldn't evaluate the client's biometry policy."))))
            return
        }

        biometryPolicy.evaluatePolicy(reasonText: reasonText) { success, error in
            guard error == nil, success else {
                completion(.init(.init(statusCode: .unauthorized,
                                       response: .init(message: "The authorization failed while evaluating the biometry policy - \(String(describing: error))"))))
                return
            }

            completion(.init(.init(response: .init(value: value))))
        }
    }

    func handleIsBiometricAuthEnabled(completion: @escaping (API.Communication.IsBiometricAuthEnabledResult) -> Void) {
        let isEnabled = IDKit.isBiometricAuthenticationEnabled()
        completion(.init(.init(response: .init(isEnabled: isEnabled))))
    }
}

private extension App {
    func secureData(for key: String) -> String? {
        let userDefaults = UserDefaults.standard // swiftlint:disable:this user_defaults_wrapper

        SDKKeychain.migrateUserScopedStringIfNeeded(key: key)

        guard let secureDataString = userDefaults.string(forKey: key) else {
            return SDKKeychain.string(for: key, isUserSensitiveData: true)
        }

        // Migrate secureData string from userDefaults to keychain
        SDKKeychain.set(secureDataString, for: key, isUserSensitiveData: true)
        userDefaults.set(nil, forKey: key)

        return secureDataString
    }

    func setSecureData(value: String, for key: String) {
        SDKKeychain.set(value, for: key, isUserSensitiveData: true)
    }

    func appTOTPData(for key: String) -> Data? {
        let userDefaults = UserDefaults.standard // swiftlint:disable:this user_defaults_wrapper

        SDKKeychain.migrateUserScopedDataIfNeeded(key: key)

        guard let userDefaultsTotpData = userDefaults.data(forKey: key) else {
            return SDKKeychain.data(for: key, isUserSensitiveData: true)
        }

        // Migrate totp data from userDefaults to keychain
        SDKKeychain.set(userDefaultsTotpData, for: key, isUserSensitiveData: true)
        userDefaults.set(nil, forKey: key)

        return userDefaultsTotpData
    }

    func masterTOTPData(host: String) -> Data? { // swiftlint:disable:this inclusive_language
        guard let domainACL = PACECloudSDK.shared.config?.domainACL,
              domainACL.contains(where: { host.hasSuffix($0) }) else {
            return nil
        }

        let secretKey = IDKit.BiometryPolicy.retrieveMasterKey()
        SDKKeychain.migrateUserScopedDataIfNeeded(key: secretKey)
        let totpData = SDKKeychain.data(for: secretKey, isUserSensitiveData: true)
        return totpData
    }

    func setAppTOTPData(to newValue: Data, for key: String, host: String) {
        // Set App TOTP Data
        SDKKeychain.set(newValue, for: key, isUserSensitiveData: true)

        // Set master TOTP Data if not available yet
        guard masterTOTPData(host: host) == nil else { return }

        let secretKey = IDKit.BiometryPolicy.retrieveMasterKey()
        SDKKeychain.set(newValue, for: secretKey, isUserSensitiveData: true)
    }
}
