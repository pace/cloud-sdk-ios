//
//  App+2FA.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Base32
import LocalAuthentication
import OneTimePassword
import WebKit

extension App {
    var userDefaults: UserDefaults {
        UserDefaults.standard
    }

    var laPolicy: LAPolicy {
        return .deviceOwnerAuthenticationWithBiometrics
    }

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

    func handleBiometryAvailabilityRequest(with request: AppKit.AppRequestData<String?>) {
        var authError: NSError?
        let isBiometryAvailable = LAContext().canEvaluatePolicy(laPolicy, error: &authError)
        jsonRpcInterceptor?.respond(id: request.id, message: isBiometryAvailable ? true : false)
   }

    func setTOTPSecret(with request: AppKit.AppRequestData<AppKit.TOTPSecretData>, requestUrl: URL?) {
        guard let host = requestUrl?.host else {
            AppKit.shared.notifyDidFail(with: .badRequest)
            jsonRpcInterceptor?.send(id: request.id, error: .badRequest)
            return
        }

        let laContext = LAContext()
        laContext.localizedFallbackTitle = "" // Removes the 'Enter password' option

        var authError: NSError?
        let reasonText = "payment.authentication.confirmation".localized

        guard laContext.canEvaluatePolicy(laPolicy, error: &authError) else {
            jsonRpcInterceptor?.send(id: request.id, error: .internalError)
            return
        }

        laContext.evaluatePolicy(laPolicy, localizedReason: reasonText) { [weak self] success, error in
            guard error == nil, success, let unwrappedSelf = self else {
                self?.jsonRpcInterceptor?.send(id: request.id, error: .internalError)
                return
            }

            do {
                let data = try PropertyListEncoder().encode(request.message)
                let secretKey: String = unwrappedSelf.retrieveKey(for: request.message.key, host: host)
                unwrappedSelf.userDefaults.set(data, forKey: secretKey)
            } catch {
                self?.jsonRpcInterceptor?.send(id: request.id, error: .internalError)
            }

            self?.jsonRpcInterceptor?.respond(id: request.id, message: [MessageHandlerParam.statusCode.rawValue: MessageHandlerStatusCode.success.statusCode])
        }
    }

    func getTOTP(with request: AppKit.AppRequestData<AppKit.GetTOTPData>, requestUrl: URL?) { // swiftlint:disable:this function_body_length
        guard let host = requestUrl?.host else {
            AppKit.shared.notifyDidFail(with: .badRequest)
            jsonRpcInterceptor?.send(id: request.id, error: .badRequest)
            return
        }

        let secretKey: String = retrieveKey(for: request.message.key, host: host)

        guard userDefaults.data(forKey: secretKey) != nil else {
            jsonRpcInterceptor?.send(id: request.id, error: .notFound)
            return
        }

        let laContext = LAContext()
        laContext.localizedFallbackTitle = "" // Removes the 'Enter password' option

        let reasonText = "payment.authentication.confirmation".localized

        var authError: NSError?

        guard laContext.canEvaluatePolicy(laPolicy, error: &authError) else {
            jsonRpcInterceptor?.send(id: request.id, error: .notAllowed)

            return
        }

        laContext.evaluatePolicy(laPolicy, localizedReason: reasonText) { [weak self] success, error in
            guard error == nil, success else {
                self?.jsonRpcInterceptor?.send(id: request.id, error: .unauthorized)
                return
            }

            guard let totp = self?.generateTOTP(with: request.message, host: host) else {
                self?.jsonRpcInterceptor?.send(id: request.id, error: .internalError)
                return
            }

            let biometryMethod: AppKit.BiometryMethod

            switch laContext.biometryType {
            case .faceID:
                biometryMethod = .face

            case .touchID:
                biometryMethod = .fingerprint

            default:
                biometryMethod = .fingerprint
            }

            self?.jsonRpcInterceptor?.respond(id: request.id, message: [MessageHandlerParam.totp.rawValue: totp,
                                                       MessageHandlerParam.biometryMethod.rawValue: biometryMethod.rawValue])
        }
    }

    private func generateTOTP(with data: AppKit.GetTOTPData, host: String) -> String? {
        let secretKey: String = retrieveKey(for: data.key, host: host)

        guard let storedData: Data = userDefaults.data(forKey: secretKey),
              let storedTOTPSecretData = try? PropertyListDecoder().decode(AppKit.TOTPSecretData.self, from: storedData) else {
                return nil
        }

        guard let secretData = MF_Base32Codec.data(fromBase32String: storedTOTPSecretData.secret), !secretData.isEmpty else { return nil }

        let algorithm: Generator.Algorithm

        switch storedTOTPSecretData.algorithm {
        case "SHA1":
            algorithm = .sha1

        case "SHA256":
            algorithm = .sha256

        case "SHA512":
            algorithm = .sha512

        default:
            algorithm = .sha1
        }

        guard let generator = Generator(
            factor: .timer(period: storedTOTPSecretData.period),
            secret: secretData,
            algorithm: algorithm,
            digits: storedTOTPSecretData.digits) else {
                return nil
        }

        let token = Token(name: "TOTP", issuer: "PACE", generator: generator)
        let time = Date(timeIntervalSince1970: data.serverTime)

        do {
            let passwordAtTime = try token.generator.password(at: time)
            return passwordAtTime
        } catch {
            // Cannot generate password for invalid time
            return nil
        }
    }

    func setSecureData(with request: AppKit.AppRequestData<AppKit.SetSecureData>, requestUrl: URL?) {
        guard let host = requestUrl?.host else {
            AppKit.shared.notifyDidFail(with: .badRequest)
            jsonRpcInterceptor?.send(id: request.id, error: .badRequest)
            return
        }

        let key = retrieveKey(for: request.message.key, host: host)

        userDefaults.set(request.message.value, forKey: key)

        jsonRpcInterceptor?.respond(id: request.id, message: [MessageHandlerParam.statusCode.rawValue: MessageHandlerStatusCode.success.statusCode])
    }

    func getSecureData(with request: AppKit.AppRequestData<AppKit.GetSecureData>, requestUrl: URL?) {
        guard let host = requestUrl?.host else {
            AppKit.shared.notifyDidFail(with: .badRequest)
            jsonRpcInterceptor?.send(id: request.id, error: .badRequest)
            return
        }

        let key = retrieveKey(for: request.message.key, host: host)
        let laContext = LAContext()
        laContext.localizedFallbackTitle = "" // Removes the 'Enter password' option

        let reasonText = "secureData.authentication.confirmation".localized

        var authError: NSError?

        guard let value = userDefaults.string(forKey: key) else {
            jsonRpcInterceptor?.send(id: request.id, error: .notFound)
            return
        }

        guard laContext.canEvaluatePolicy(laPolicy, error: &authError) else {
            jsonRpcInterceptor?.send(id: request.id, error: .notAllowed)
            return
        }

        laContext.evaluatePolicy(laPolicy, localizedReason: reasonText) { [weak self] success, error in
            guard error == nil, success else {
                self?.jsonRpcInterceptor?.send(id: request.id, error: .unauthorized)
                return
            }

            self?.jsonRpcInterceptor?.respond(id: request.id, message: [MessageHandlerParam.value.rawValue: value])
        }
    }
}
