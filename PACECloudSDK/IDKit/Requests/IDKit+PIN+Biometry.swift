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
        guard let accessToken = IDKit.latestAccessToken() else {
            completion(.failure(.invalidSession))
            return
        }

        let request = UserAPI.Credentials.CheckUserPinOrPassword.Request()

        makeRequest(request, accessToken: accessToken) { [weak self] response in
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

    func setPIN(pin: String, password: String, completion: @escaping (Result<Bool, IDKitError>) -> Void) {
        otp(for: password) { [weak self] result in
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
        guard let accessToken = IDKit.latestAccessToken() else {
            completion(.failure(.invalidSession))
            return
        }

        let pinData = PCUserUserPIN(attributes: .init(pin: pin, otp: otp), type: .pin)
        let request = UserAPI.Credentials.UpdateUserPIN.Request(body: .init(data: pinData))

        makeRequest(request, accessToken: accessToken) { [weak self] response in
            switch response.result {
            case .success(let result):
                if result.statusCode == HttpStatusCode.notAcceptable.rawValue {
                    completion(.failure(.pinNotSecure))
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
        guard IDKit.latestAccessToken() != nil else { return false }
        let isSet = masterTOTPData() != nil
        return isSet
    }

    func enableBiometricAuthentication(pin: String?, password: String?, otp: String?, completion: ((Result<Bool, IDKitError>) -> Void)?) {
        guard let accessToken = IDKit.latestAccessToken() else {
            completion?(.failure(.invalidSession))
            return
        }

        let totpData = PCUserDeviceTOTP(attributes: .init(otp: otp, password: password, pin: pin), id: UUID().uuidString.lowercased(), type: .deviceTOTP)
        let request = UserAPI.TOTP.CreateTOTP.Request(body: .init(data: totpData))

        makeRequest(request, accessToken: accessToken) { [weak self] response in
            switch response.result {
            case .success(let result):
                if result.statusCode == HttpStatusCode.forbidden.rawValue {
                    completion?(.failure(.invalidCredentials))
                    return
                }

                guard let attributes = result.success?.data?.attributes,
                      let totpData = BiometryTOTPData(from: attributes) else {
                    completion?(.failure(.internalError))
                    return
                }

                let biometryPolicy = BiometryPolicy()
                let reasonText = "payment.authentication.confirmation".localized

                guard biometryPolicy.canEvaluatePolicy else {
                    completion?(.failure(.biometryNotSupported))
                    return
                }

                biometryPolicy.evaluatePolicy(reasonText: reasonText) { [weak self] success, error in
                    guard error == nil, success else {
                        completion?(.failure(.failedAuthenticatingBiometry))
                        return
                    }

                    do {
                        let data = try PropertyListEncoder().encode(totpData)
                        self?.setMasterTOTPData(to: data)
                        completion?(.success(true))
                    } catch {
                        completion?(.failure(.internalError))
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

    func otp(for password: String, completion: @escaping (Result<String, IDKitError>) -> Void) {
        guard let accessToken = IDKit.latestAccessToken() else {
            completion(.failure(.invalidSession))
            return
        }

        let totpData = PCUserCreateOTP(password: password)
        let request = UserAPI.TOTP.CreateOTP.Request(body: totpData)

        makeRequest(request, accessToken: accessToken) { response in
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
        guard IDKit.latestAccessToken() != nil else {
            completion(.failure(.invalidSession))
            return
        }

        guard let totpData = masterTOTPData() else {
            completion(.failure(.biometryNotFound))
            return
        }

        let biometryPolicy = BiometryPolicy()
        let reasonText = "payment.authentication.confirmation".localized

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
        guard let accessToken = IDKit.latestAccessToken() else {
            completion(.failure(.invalidSession))
            return
        }

        makeRequest(request, accessToken: accessToken) { [weak self] response in
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

    func makeRequest<T>(_ request: UserAPIRequest<T>, accessToken: String, completion: @escaping (UserAPIResponse<T>) -> Void) where T: APIResponseValue {
        addAuthorizationHeader(to: request, with: accessToken)
        API.User.client.makeRequest(request, complete: completion)
    }

    func addAuthorizationHeader<T>(to request: UserAPIRequest<T>, with accessToken: String) {
        request.customHeaders[HttpHeaderFields.authorization.rawValue] = "Bearer \(accessToken)"
    }
}

// MARK: - Biometry Data
private extension IDKit {
    func masterTOTPData() -> Data? {
        let secretKey = BiometryPolicy.retrieveMasterKey()
        let totpData = Keychain().getData(for: secretKey)
        return totpData
    }

    func setMasterTOTPData(to newValue: Data?) {
        let keychain = Keychain()
        let secretKey = BiometryPolicy.retrieveMasterKey()

        guard let newValue = newValue else {
            keychain.delete(secretKey)
            return
        }

        keychain.set(newValue, for: secretKey)
    }
}
