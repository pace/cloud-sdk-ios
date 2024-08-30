//
//  IDKit+Concurrency.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

@MainActor
extension IDKit {
    func checkedContinuation<T>(_ request: (@escaping (T) -> Void) -> Void) async -> T {
        await withCheckedContinuation { continuation in
            request { result in
                continuation.resume(returning: result)
            }
        }
    }
}

// MARK: - Discovery

public extension IDKit {

    /// Performs a discovery to retrieve an OID configuration.
    ///
    /// - Parameter issueUrl: The issuer url.
    /// - Returns: An asynchronously-delivered result
    /// that either contains the OID configuration response or an error.
    static func discoverConfiguration(issuerUrl: String) async -> Result<OIDConfiguration.Response, IDKitError> {
        await performDiscovery(issuerUrl: issuerUrl)
    }
}

// MARK: - Token / Session handling

public extension IDKit {

    /// Performs an OID authorization request.
    ///
    /// - Returns: An asynchronously-delivered result
    /// that either contains a valid access token or and error.
    static func authorize() async -> Result<String?, IDKitError> {
        await shared?.performAuthorization(showSignInMask: false) ?? .failure(.missingSetup)
    }

    /// Refreshes the current access token if needed.
    ///
    /// - Returns: An asynchronously-delivered result
    /// that either contains a new valid access token or an error.
    static func refreshToken() async -> Result<String?, IDKitError> {
        await shared?.performRefresh() ?? .failure(.missingSetup)
    }

    /// Asynchronously cancels the authorization flow
    /// and invokes the `authorize()` completion block with a `cancelled` error.
    ///
    /// Has no effect when calling multiple times.
    static func cancelAuthorizationFlow() async {
        await shared?.performCancelAuthorizationFlow()
    }

    /// Resets the current session.
    ///
    /// - Returns: An asynchronously-delivered result
    /// that either contains `Void` in case the reset has been successful or an error.
    static func resetSession() async -> Result<Void, IDKit.IDKitError> {
        await shared?.performReset() ?? .failure(.missingSetup)
    }
}

// MARK: - User

public extension IDKit {

    /// Retrieves the currently authorized user's information.
    ///
    /// - Returns: An asynchronously-delivered result
    /// that either contains a `UserInfo` object or an error.
    static func userInfo() async -> Result<UserInfo, IDKitError> {
        await shared?.userInfo() ?? .failure(.missingSetup)
    }

    /// Fetches a list of valid payment methods for the current user.
    ///
    /// - Returns: An asynchronously-delivered result
    /// that either contains an array of `PCPayPaymentMethod` or an error.
    static func paymentMethods() async -> Result<PCPayPaymentMethods, IDKitError> {
        await shared?.paymentMethods() ?? .failure(.missingSetup)
    }

    /// Fetches a list of transactions for the current user sorted in descending order by creation date.
    ///
    /// - Returns: An asynchronously-delivered result
    /// that either contains an array of `PCPayTransaction` or an error.
    static func transactions() async -> Result<PCPayTransactions, IDKitError> {
        await shared?.transactions() ?? .failure(.missingSetup)
    }
}

// MARK: - PIN / Biometry

public extension IDKit {

    /// Checks if there is an active password set for the currently authenticated user.
    ///
    /// - Returns: An asynchronously-delivered result
    /// that either contains the status of the current password or an error.
    static func isPasswordSet() async -> Result<Bool, IDKitError> {
        await shared?.isPasswordSet() ?? .failure(.missingSetup)
    }

    /// Checks if there is an active PIN set for the currently authenticated user.
    ///
    /// - Returns: An asynchronously-delivered result
    /// that either contains the status of the current PIN or an error.
    static func isPINSet() async -> Result<Bool, IDKitError> {
        await shared?.isPINSet() ?? .failure(.missingSetup)
    }

    /// Checks if there is an active PIN or password set for the currently authenticated user.
    ///
    /// - Returns: An asynchronously-delivered result
    /// that either contains the status of the current password and PIN or an error.
    static func isPINOrPasswordSet() async -> Result<Bool, IDKitError> {
        await shared?.isPINOrPasswordSet() ?? .failure(.missingSetup)
    }

    /// Sets or updates the user's PIN.
    ///
    /// - Parameter pin: The PIN to be set.
    /// - Parameter password: The password that needs to be provided to successfully set or update the PIN.
    /// - Returns: An asynchronously-delivered result
    /// that either contains the status of this operation or an error.
    static func setPIN(pin: String, password: String) async -> Result<Bool, IDKitError> {
        await shared?.setPIN(pin: pin, password: password) ?? .failure(.missingSetup)
    }

    /// Sets or updates the user's PIN.
    ///
    /// - Parameter pin: The PIN to be set.
    /// - Parameter otp: The OTP that needs to be provided to successfully set or update the PIN.
    /// - Returns: An asynchronously-delivered result
    /// that either contains the status of this operation or an error.
    static func setPIN(pin: String, otp: String) async -> Result<Bool, IDKitError> {
        await shared?.setPIN(pin: pin, otp: otp) ?? .failure(.missingSetup)
    }

    /// Sets or updates the user's PIN.
    ///
    /// - Parameter pin: The PIN to be set.
    /// - Parameter otp: The OTP that additionally needs to be provided to successfully set or update the PIN.
    /// - Returns: An asynchronously-delivered result
    /// that either contains the status of this operation or an error.
    static func setPINWithBiometry(pin: String) async -> Result<Bool, IDKitError> {
        await shared?.setPINWithBiometry(pin: pin) ?? .failure(.missingSetup)
    }

    /// Evaluates the use of biometric authentication.
    ///
    /// This method asynchronously evaluates the biometric authentication policy.
    /// It may involve prompting the user for interaction.
    ///
    /// - Returns: An asynchronously-delivered result
    /// that either contains the status of this operation or an error.
    static func evaluateBiometryPolicy() async -> Result<Bool, IDKitError> {
        await shared?.evaluateBiometryPolicy() ?? .failure(.missingSetup)
    }

    /// Enables biometric authentication for the current user using the PIN.
    ///
    /// - Parameter pin: The PIN of the current user.
    /// - Returns: An asynchronously-delivered result
    /// that either contains the status of this operation or an error.
    static func enableBiometricAuthentication(pin: String) async -> Result<Bool, IDKitError> {
        await shared?.enableBiometricAuthentication(pin: pin, password: nil, otp: nil) ?? .failure(.missingSetup)
    }

    /// Enables biometric authentication for the current user using the account password.
    ///
    /// - Parameter password: The password of the current user.
    /// - Returns: An asynchronously-delivered result
    /// that either contains the status of this operation or an error.
    static func enableBiometricAuthentication(password: String) async -> Result<Bool, IDKitError> {
        await shared?.enableBiometricAuthentication(pin: nil, password: password, otp: nil) ?? .failure(.missingSetup)
    }

    /// Enables biometric authentication for the current user using an OTP.
    ///
    /// - Parameter otp: The OTP for the user.
    /// - Returns: An asynchronously-delivered result
    /// that either contains the status of this operation or an error.
    static func enableBiometricAuthentication(otp: String) async -> Result<Bool, IDKitError> {
        await shared?.enableBiometricAuthentication(pin: nil, password: nil, otp: otp) ?? .failure(.missingSetup)
    }

    /// Enables biometric authentication for the current user.
    ///
    /// This request will only succeed if called directly after an authorization.
    ///
    /// - Returns: An asynchronously-delivered result
    /// that either contains the status of this operation or an error.
    static func enableBiometricAuthentication() async -> Result<Bool, IDKitError> {
        await shared?.enableBiometricAuthentication(pin: nil, password: nil, otp: nil) ?? .failure(.missingSetup)
    }

    /// Sends a mail to the user that provides an OTP.
    ///
    /// - Returns: An asynchronously-delivered result
    /// that either contains the status of this operation or an error.
    static func sendMailOTP() async -> Result<Bool, IDKitError> {
        await shared?.sendMailOTP() ?? .failure(.missingSetup)
    }

    /// Generates an OTP by using biometry evaluation.
    ///
    /// - Returns: An asynchronously-delivered result
    /// that either contains the generated OTP or an error.
    static func generateOTPWithBiometry() async -> Result<String, IDKitError> {
        await shared?.otpWithBiometry() ?? .failure(.missingSetup)
    }

    /// Generates an OTP by using the user's PACE PIN.
    ///
    /// - Parameter pin: The user's PACE PIN.
    /// - Returns: An asynchronously-delivered result
    /// that either contains the generated OTP or an error.
    static func generateOTP(pin: String) async -> Result<String, IDKitError> {
        await shared?.otp(password: nil, pin: pin) ?? .failure(.missingSetup)
    }

    /// Generates an OTP by using the user's PACE ID password.
    ///
    /// - Parameter password: The user's PACE ID password.
    /// - Returns: An asynchronously-delivered result
    /// that either contains the generated OTP or an error.
    static func generateOTP(password: String) async -> Result<String, IDKitError> {
        await shared?.otp(password: password, pin: nil) ?? .failure(.missingSetup)
    }
}
