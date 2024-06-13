//
//  IDKit+Slim.swift
//  PACECloudSlimSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

extension IDKit {
    static func performDiscovery(issuerUrl: String, _ completion: @escaping (Result<OIDConfiguration.Response, IDKitError>) -> Void) {}
}

extension IDKit {
    func isPasswordSet(completion: @escaping (Result<Bool, IDKitError>) -> Void) {}
    func isPINSet(completion: @escaping (Result<Bool, IDKitError>) -> Void) {}
    func isPINOrPasswordSet(completion: @escaping (Result<Bool, IDKitError>) -> Void) {}
    func isPINValid(pin: String) -> Bool { false }
    func setPIN(pin: String, password: String, completion: @escaping (Result<Bool, IDKitError>) -> Void) {}
    func setPINWithBiometry(pin: String, completion: @escaping (Result<Bool, IDKitError>) -> Void) {}
    func setPIN(pin: String, otp: String, completion: @escaping (Result<Bool, IDKitError>) -> Void) {}
    func isBiometricAuthenticationEnabled() -> Bool { false }
    func evaluateBiometryPolicy(completion: @escaping (Result<Bool, IDKitError>) -> Void) {}
    func enableBiometricAuthentication(pin: String?, password: String?, otp: String?, completion: ((Result<Bool, IDKitError>) -> Void)?) {}
    func disableBiometricAuthentication() {}
    func otp(password: String?, pin: String?, completion: @escaping (Result<String, IDKitError>) -> Void) {}
    func otpWithBiometry(completion: @escaping (Result<String, IDKitError>) -> Void) {}
    func sendMailOTP(completion: @escaping (Result<Bool, IDKitError>) -> Void) {}
}

public extension IDKit {
    struct UserInfo {}
    class PCPayPaymentMethods {}
    class PCPayTransactions {}
}

extension IDKit {
    func userInfo(completion: @escaping (Result<UserInfo, IDKitError>) -> Void) {}
    func paymentMethods(completion: @escaping (Result<PCPayPaymentMethods, IDKitError>) -> Void) {}
    func transactions(completion: @escaping (Result<PCPayTransactions, IDKitError>) -> Void) {}
}

extension IDKit {
    static func performDiscovery(issuerUrl: String) async -> Result<OIDConfiguration.Response, IDKitError> { .failure(.internalError) }

    func userInfo() async -> Result<UserInfo, IDKitError> { .failure(.internalError) }
    func paymentMethods() async -> Result<PCPayPaymentMethods, IDKitError> { .failure(.internalError) }
    func transactions() async -> Result<PCPayTransactions, IDKitError> { .failure(.internalError) }

    func isPasswordSet() async -> Result<Bool, IDKitError> { .failure(.internalError) }
    func isPINSet() async -> Result<Bool, IDKitError> { .failure(.internalError) }
    func isPINOrPasswordSet() async -> Result<Bool, IDKitError> { .failure(.internalError) }
    func setPIN(pin: String, password: String) async -> Result<Bool, IDKitError> { .failure(.internalError) }
    func setPINWithBiometry(pin: String) async -> Result<Bool, IDKitError> { .failure(.internalError) }
    func setPIN(pin: String, otp: String) async -> Result<Bool, IDKitError> { .failure(.internalError) }
    func evaluateBiometryPolicy() async -> Result<Bool, IDKitError> { .failure(.internalError) }
    func enableBiometricAuthentication(pin: String?, password: String?, otp: String?) async -> Result<Bool, IDKitError> { .failure(.internalError) }
    func otp(password: String?, pin: String?) async -> Result<String, IDKitError> { .failure(.internalError) }
    func otpWithBiometry() async -> Result<String, IDKitError> { .failure(.internalError) }
    func sendMailOTP() async -> Result<Bool, IDKitError> { .failure(.internalError) }
}
