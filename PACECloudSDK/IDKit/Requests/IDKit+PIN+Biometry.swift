//
//  IDKit+PIN+Biometry.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation
import LocalAuthentication

extension IDKit {

    // MARK: - PIN / Password

    func isPasswordSet(completion: @escaping (Result<Bool, IDKitError>) -> Void) {
        let request = UserAPI.Credentials.CheckUserPassword.Request()
        makeBoolRequest(with: request, completion: completion)
    }

    func isPINSet(completion: @escaping (Result<Bool, IDKitError>) -> Void) {
        let request = UserAPI.Credentials.CheckUserPIN.Request()
        makeBoolRequest(with: request, completion: completion)
    }

    func isPINOrPasswordSet(completion: @escaping (Result<Bool, IDKitError>) -> Void) {
        let request = UserAPI.Credentials.CheckUserPinOrPassword.Request()

        API.User.client.makeRequest(request) { [weak self] response in
            switch response.result {
            case .success(let result):
                guard let data = result.success else {
                    completion(.failure(.internalError))
                    return
                }

                completion(.success(data.pin == true || data.password == true))

            case .failure:
                self?.checkBoolRequestFailureCase(for: response, completion: completion)
            }
        }
    }

    func isPINValid(pin: String) -> Bool {
        let charSet = Set(pin.enumerated().map { $0.element })
        let charChain = "0123456789012"

        return pin.count == 4
            && charSet.count >= 3
            && !charChain.contains(pin)
            && !charChain.reversed().map({ String($0) }).joined().contains(pin)
    }

    func setPIN(pin: String, password: String, completion: @escaping (Result<Bool, IDKitError>) -> Void) {
        otp(password: password, pin: nil) { [weak self] result in
            switch result {
            case .success(let otp):
                self?.setPIN(pin: pin, otp: otp, completion: completion)

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func setPINWithBiometry(pin: String, completion: @escaping (Result<Bool, IDKitError>) -> Void) {
        otpWithBiometry { [weak self] result in
            switch result {
            case .success(let otp):
                self?.setPIN(pin: pin, otp: otp, completion: completion)

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func setPIN(pin: String, otp: String, completion: @escaping (Result<Bool, IDKitError>) -> Void) {
        logBiometryWarningsIfNeeded()

        let pinData = PCUserUserPINAndOTPRequest(attributes: .init(pin: pin, otp: otp), type: .pin)
        let request = UserAPI.Credentials.UpdateUserPIN.Request(body: .init(data: pinData))

        API.User.client.makeRequest(request) { [weak self] response in
            switch response.result {
            case .success(let result):
                if result.statusCode == HttpStatusCode.notAcceptable.rawValue {
                    completion(.failure(.pinNotSecure))
                } else if result.statusCode == HttpStatusCode.forbidden.rawValue {
                    completion(.failure(.invalidCredentials))
                } else {
                    completion(.success(result.successful))
                }

            case .failure:
                self?.checkBoolRequestFailureCase(for: response, completion: completion)
            }
        }
    }

    // MARK: - Biometry

    func isBiometricAuthenticationEnabled() -> Bool {
        logBiometryWarningsIfNeeded()

        guard IDKit.latestAccessToken() != nil else { return false }
        let isSet = masterTOTPData() != nil
        return isSet
    }

    func evaluateBiometryPolicy(completion: @escaping (Result<Bool, IDKitError>) -> Void) {
        let biometryPolicy = BiometryPolicy()
        let reasonText = PACECloudSDK.shared.localizable.idkitBiometryAuthenticationConfirmation

        guard biometryPolicy.canEvaluatePolicy else {
            completion(.failure(.biometryNotSupported))
            return
        }

        biometryPolicy.evaluatePolicy(reasonText: reasonText) { success, error in
            if let error = error {
                completion(.failure(.other(error)))
                return
            }

            guard success else {
                completion(.failure(.failedAuthenticatingBiometry))
                return
            }

            completion(.success(success))
        }
    }

    func enableBiometricAuthentication(pin: String?, password: String?, otp: String?, completion: ((Result<Bool, IDKitError>) -> Void)?) {
        logBiometryWarningsIfNeeded()

        let totpData = PCUserDeviceTOTPRequest(attributes: .init(otp: otp, password: password, pin: pin), id: UUID().uuidString.lowercased(), type: .deviceTOTP)
        let request = UserAPI.TOTP.CreateTOTP.Request(body: .init(data: totpData))

        API.User.client.makeRequest(request) { [weak self] response in
            switch response.result {
            case .success(let result):
                if result.statusCode == HttpStatusCode.forbidden.rawValue {
                    completion?(.failure(.invalidCredentials))
                    return
                }

                guard let data = result.success?.data,
                      let totpData = BiometryTOTPData(from: data) else {
                    completion?(.failure(.internalError))
                    return
                }

                self?.evaluateBiometryPolicy { result in
                    switch result {
                    case .success(let isSuccessful):
                        guard isSuccessful else {
                            completion?(.failure(.failedAuthenticatingBiometry))
                            return
                        }

                        do {
                            let data = try JSONEncoder().encode(totpData)
                            self?.setMasterTOTPData(to: data)
                            completion?(.success(true))
                        } catch {
                            completion?(.failure(.internalError))
                        }

                    case .failure:
                        completion?(.failure(.failedAuthenticatingBiometry))
                    }
                }

            case .failure:
                self?.checkBoolRequestFailureCase(for: response, completion: completion)
            }
        }
    }

    func disableBiometricAuthentication() {
        setMasterTOTPData(to: nil)
    }

    // MARK: - OTP

    func otp(password: String?, pin: String?, completion: @escaping (Result<String, IDKitError>) -> Void) {
        let totpData = PCUserCreateOTPRequest(password: password, pin: pin)
        let request = UserAPI.TOTP.CreateOTP.Request(body: totpData)

        API.User.client.makeRequest(request) { response in
            switch response.result {
            case .success(let result):
                if result.statusCode >= HttpStatusCode.notFound.rawValue {
                    completion(.failure(.invalidCredentials))
                    return
                }

                guard let otp = result.success?.otp else {
                    completion(.failure(.internalError))
                    return
                }

                completion(.success(otp))

            case .failure(let error):
                guard let statusCode = response.urlResponse?.statusCode else {
                    completion(.failure(.internalError))
                    return
                }

                if statusCode >= HttpStatusCode.internalError.rawValue {
                    completion(.failure(.internalError))
                } else if statusCode == HttpStatusCode.unauthorized.rawValue {
                    completion(.failure(.invalidSession))
                } else {
                    completion(.failure(.other(error)))
                }
            }
        }
    }

    func otpWithBiometry(completion: @escaping (Result<String, IDKitError>) -> Void) {
        guard let totpData = masterTOTPData() else {
            completion(.failure(.biometryNotFound))
            return
        }

        let biometryPolicy = BiometryPolicy()
        let reasonText = PACECloudSDK.shared.localizable.idkitBiometryAuthenticationConfirmation

        guard biometryPolicy.canEvaluatePolicy else {
            completion(.failure(.biometryNotSupported))
            return
        }

        biometryPolicy.evaluatePolicy(reasonText: reasonText) { success, error in
            guard error == nil, success else {
                completion(.failure(.failedAuthenticatingBiometry))
                return
            }

            guard let totp = BiometryPolicy.generateTOTP(with: totpData, timeIntervalSince1970: Date().timeIntervalSince1970) else {
                completion(.failure(.internalError))
                return
            }

            completion(.success(totp))
        }
    }

    func sendMailOTP(completion: @escaping (Result<Bool, IDKitError>) -> Void) {
        let request = UserAPI.TOTP.SendmailOTP.Request()
        makeBoolRequest(with: request, completion: completion)
    }
}

// MARK: - Requests
private extension IDKit {
    func makeBoolRequest<T>(with request: UserAPIRequest<T>, completion: @escaping (Result<Bool, IDKitError>) -> Void) {
        API.User.client.makeRequest(request) { [weak self] response in
            switch response.result {
            case .success(let result):
                completion(.success(result.successful))

            case .failure:
                self?.checkBoolRequestFailureCase(for: response, completion: completion)
            }
        }
    }

    func checkBoolRequestFailureCase<T>(for response: UserAPIResponse<T>, completion: ((Result<Bool, IDKitError>) -> Void)?) {
        guard let statusCode = response.urlResponse?.statusCode else {
            completion?(.failure(.internalError))
            return
        }

        if statusCode >= HttpStatusCode.internalError.rawValue {
            completion?(.failure(.internalError))
        } else if statusCode == HttpStatusCode.unauthorized.rawValue {
            completion?(.failure(.invalidSession))
        } else {
            completion?(.success(false))
        }
    }
}

// MARK: - Biometry Data
private extension IDKit {
    func masterTOTPData() -> Data? { // swiftlint:disable:this inclusive_language
        let secretKey = BiometryPolicy.retrieveMasterKey()
        SDKKeychain.migrateUserScopedDataIfNeeded(key: secretKey)
        let totpData = SDKKeychain.data(for: secretKey, isUserSensitiveData: true)
        return totpData
    }

    func setMasterTOTPData(to newValue: Data?) { // swiftlint:disable:this inclusive_language
        let secretKey = BiometryPolicy.retrieveMasterKey()

        guard let newValue = newValue else {
            SDKKeychain.deleteAllTOTPData()
            return
        }

        SDKKeychain.set(newValue, for: secretKey, isUserSensitiveData: true)
    }

    func logBiometryWarningsIfNeeded() {
        PACECloudSDK.shared.warningsHandler?.logBiometryWarningsIfNeeded()
    }
}

// MARK: - Concurrency

@MainActor
extension IDKit {
    func isPasswordSet() async -> Result<Bool, IDKitError> {
        await checkedContinuation(isPasswordSet)
    }

    func isPINSet() async -> Result<Bool, IDKitError> {
        await checkedContinuation(isPINSet)
    }

    func isPINOrPasswordSet() async -> Result<Bool, IDKitError> {
        await checkedContinuation(isPINOrPasswordSet)
    }

    func setPIN(pin: String, password: String) async -> Result<Bool, IDKitError> {
        await checkedContinuation { [weak self] completion in
            self?.setPIN(pin: pin, password: password, completion: completion)
        }
    }

    func setPINWithBiometry(pin: String) async -> Result<Bool, IDKitError> {
        await checkedContinuation { [weak self] completion in
            self?.setPINWithBiometry(pin: pin, completion: completion)
        }
    }

    func setPIN(pin: String, otp: String) async -> Result<Bool, IDKitError> {
        await checkedContinuation { [weak self] completion in
            self?.setPIN(pin: pin, otp: otp, completion: completion)
        }
    }

    func evaluateBiometryPolicy() async -> Result<Bool, IDKitError> {
        await checkedContinuation(evaluateBiometryPolicy)
    }

    func enableBiometricAuthentication(pin: String?, password: String?, otp: String?) async -> Result<Bool, IDKitError> {
        await checkedContinuation { [weak self] completion in
            self?.enableBiometricAuthentication(pin: pin, password: password, otp: otp, completion: completion)
        }
    }

    func otp(password: String?, pin: String?) async -> Result<String, IDKitError> {
        await checkedContinuation { [weak self] completion in
            self?.otp(password: password, pin: pin, completion: completion)
        }
    }

    func otpWithBiometry() async -> Result<String, IDKitError> {
        await checkedContinuation(otpWithBiometry)
    }

    func sendMailOTP() async -> Result<Bool, IDKitError> {
        await checkedContinuation(sendMailOTP)
    }
}
