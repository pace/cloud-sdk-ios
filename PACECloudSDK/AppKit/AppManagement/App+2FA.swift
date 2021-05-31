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

        return "\(DeviceInformation.id)_\(host)_\(key)"
    }

    func handleBiometryAvailabilityRequest(with request: AppKit.EmptyRequestData) {
        let isBiometryAvailable = BiometryPolicy().isBiometryAvailable
        messageInterceptor?.respond(id: request.id, message: isBiometryAvailable ? true : false)
   }

    func setTOTPSecret(with request: AppKit.AppRequestData<AppKit.TOTPSecretData>, requestUrl: URL?, completion: @escaping () -> Void) {
        guard let host = requestUrl?.host else {
            AppKit.shared.notifyDidFail(with: .badRequest)
            messageInterceptor?.send(id: request.id, error: .badRequest)
            completion()
            return
        }

        let biometryPolicy = BiometryPolicy()
        let reasonText = L10n.appkitSecureDataAuthenticationConfirmation

        guard biometryPolicy.canEvaluatePolicy else {
            messageInterceptor?.send(id: request.id, error: .notAllowed)
            completion()
            return
        }

        biometryPolicy.evaluatePolicy(reasonText: reasonText) { [weak self] success, error in
            defer {
                completion()
            }

            guard error == nil, success, let unwrappedSelf = self else {
                self?.messageInterceptor?.send(id: request.id, error: .internalError)
                return
            }

            do {
                let data = try PropertyListEncoder().encode(request.message)
                let secretKey: String = unwrappedSelf.retrieveKey(for: request.message.key, host: host)
                unwrappedSelf.setAppTOTPData(to: data, for: secretKey)
            } catch {
                unwrappedSelf.messageInterceptor?.send(id: request.id, error: .internalError)
            }

            unwrappedSelf.messageInterceptor?.respond(id: request.id, message: [MessageHandlerParam.statusCode.rawValue: MessageHandlerStatusCode.success.statusCode])
        }
    }

    func getTOTP(with request: AppKit.AppRequestData<AppKit.GetTOTPData>, requestUrl: URL?, completion: @escaping () -> Void) {
        guard let host = requestUrl?.host else {
            AppKit.shared.notifyDidFail(with: .badRequest)
            messageInterceptor?.send(id: request.id, error: .badRequest)
            completion()
            return
        }

        let secretKey: String = retrieveKey(for: request.message.key, host: host)

        guard let totpData = appTOTPData(for: secretKey) ?? masterTOTPData(host: host) else {
            messageInterceptor?.send(id: request.id, error: .notFound)
            completion()
            return
        }

        let biometryPolicy = BiometryPolicy()
        let reasonText = L10n.appkitSecureDataAuthenticationConfirmation

        guard biometryPolicy.canEvaluatePolicy else {
            messageInterceptor?.send(id: request.id, error: .notAllowed)
            completion()
            return
        }

        biometryPolicy.evaluatePolicy(reasonText: reasonText) { [weak self] success, error in
            defer {
                completion()
            }

            guard error == nil, success else {
                self?.messageInterceptor?.send(id: request.id, error: .unauthorized)
                return
            }

            guard let totp = BiometryPolicy.generateTOTP(with: totpData, timeIntervalSince1970: request.message.serverTime) else {
                self?.messageInterceptor?.send(id: request.id, error: .internalError)
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

            self?.messageInterceptor?.respond(id: request.id, message: [MessageHandlerParam.totp.rawValue: totp,
                                                       MessageHandlerParam.biometryMethod.rawValue: biometryMethod.rawValue])
        }
    }

    func setSecureData(with request: AppKit.AppRequestData<AppKit.SetSecureData>, requestUrl: URL?) {
        guard let host = requestUrl?.host else {
            AppKit.shared.notifyDidFail(with: .badRequest)
            messageInterceptor?.send(id: request.id, error: .badRequest)
            return
        }

        let key = retrieveKey(for: request.message.key, host: host)
        setSecureData(value: request.message.value, for: key)

        messageInterceptor?.respond(id: request.id, message: [MessageHandlerParam.statusCode.rawValue: MessageHandlerStatusCode.success.statusCode])
    }

    func getSecureData(with request: AppKit.AppRequestData<AppKit.GetSecureData>, requestUrl: URL?, completion: @escaping () -> Void) {
        guard let host = requestUrl?.host else {
            AppKit.shared.notifyDidFail(with: .badRequest)
            messageInterceptor?.send(id: request.id, error: .badRequest)
            completion()
            return
        }

        let key = retrieveKey(for: request.message.key, host: host)

        guard let value = secureData(for: key) else {
            messageInterceptor?.send(id: request.id, error: .notFound)
            completion()
            return
        }

        let biometryPolicy = BiometryPolicy()
        let reasonText = L10n.appkitSecureDataAuthenticationConfirmation

        guard biometryPolicy.canEvaluatePolicy else {
            messageInterceptor?.send(id: request.id, error: .notAllowed)
            completion()
            return
        }

        biometryPolicy.evaluatePolicy(reasonText: reasonText) { [weak self] success, error in
            defer {
                completion()
            }

            guard error == nil, success else {
                self?.messageInterceptor?.send(id: request.id, error: .unauthorized)
                return
            }

            self?.messageInterceptor?.respond(id: request.id, message: [MessageHandlerParam.value.rawValue: value])
        }
    }
}

private extension App {
    func secureData(for key: String) -> String? {
        let userDefaults = UserDefaults.standard
        let keychain = PACECloudSDK.Keychain()

        guard let secureDataString = userDefaults.string(forKey: key) else {
            return keychain.getString(for: key)
        }

        // Migrate secureData string from userDefaults to keychain
        keychain.set(secureDataString, for: key)
        userDefaults.set(nil, forKey: key)

        return secureDataString
    }

    func setSecureData(value: String, for key: String) {
        PACECloudSDK.Keychain().set(value, for: key)
    }

    func appTOTPData(for key: String) -> Data? {
        let userDefaults = UserDefaults.standard
        let keychain = PACECloudSDK.Keychain()

        guard let userDefaultsTotpData = userDefaults.data(forKey: key) else {
            return keychain.getData(for: key)
        }

        // Migrate totp data from userDefaults to keychain
        keychain.set(userDefaultsTotpData, for: key)
        userDefaults.set(nil, forKey: key)

        return userDefaultsTotpData
    }

    func masterTOTPData(host: String) -> Data? { // swiftlint:disable:this inclusive_language
        guard let domainACL = PACECloudSDK.shared.config?.domainACL,
              domainACL.contains(where: { host.hasSuffix($0) }) else {
            return nil
        }

        let secretKey = BiometryPolicy.retrieveMasterKey()
        let totpData = PACECloudSDK.Keychain().getData(for: secretKey)
        return totpData
    }

    func setAppTOTPData(to newValue: Data, for key: String) {
        PACECloudSDK.Keychain().set(newValue, for: key)
    }
}
