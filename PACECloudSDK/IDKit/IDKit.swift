//
//  IDKit.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import AppAuth

public class IDKit {
    static var shared: IDKit? {
        PACECloudSDK.shared.warningsHandler?.logSDKWarningsIfNeeded()
        return sharedInternal
    }

    static var isSetUp: Bool {
        sharedInternal != nil
    }

    static var isSessionAvailable: Bool {
        sharedInternal?.session != nil
    }

    private static var sharedInternal: IDKit?

    weak var delegate: IDKitDelegate?

    var session: OIDAuthState?
    var authorizationFlow: OIDExternalUserAgentSession?
    var configuration: OIDConfiguration

    var clientPresentingViewController: UIViewController?
    var paceIDSignInWindow: PaceIDSignInWindow?

    private init(with configuration: OIDConfiguration) {
        self.configuration = configuration

        guard let session = SessionCache.loadSession() else { return }
        self.session = session
    }

    private static func setup(with configuration: OIDConfiguration) {
        sharedInternal = IDKit(with: configuration)
    }

    static func determineOIDConfiguration(with customOIDConfig: OIDConfiguration?) {
        if let customOIDConfig = customOIDConfig {
            setup(with: customOIDConfig)
        } else if let oidConfigClientId = Bundle.main.oidConfigClientId,
                  let oidConfigRedirectUri = Bundle.main.oidConfigRedirectUri {
            let defaultOIDConfiguration = OIDConfiguration.defaultOIDConfiguration(clientId: oidConfigClientId,
                                                                                   redirectUri: oidConfigRedirectUri,
                                                                                   idpHint: Bundle.main.oidConfigIdpHint)
            setup(with: defaultOIDConfiguration)
        }
    }

    static func appInducedAuthorization(_ completion: @escaping (String?) -> Void) {
        shared?.performAppInducedAuthorization(completion)
    }

    static func appInducedRefresh(_ completion: @escaping (String?) -> Void) {
        shared?.performAppInducedRefresh(completion)
    }

    static func appInducedSessionReset(with error: IDKitError? = nil, _ completion: @escaping (String?) -> Void) {
        shared?.performAppInducedSessionReset(with: error, completion)
    }

    static func apiInducedRefresh(_ completion: @escaping (Bool) -> Void) {
        shared?.performApiInducedRefresh(completion)
    }

    func presentSignInWindow() {
        paceIDSignInWindow = PaceIDSignInWindow.create()
    }
}

// MARK: - Setup
public extension IDKit {
    /**
     Sets the delegate of IDKit.
     */
    static var delegate: IDKitDelegate? {
        get { shared?.delegate }
        set { shared?.delegate = newValue }
    }

    /**
     Sets the view controller instance that will present the sign in mask.
     */
    static var presentingViewController: UIViewController? {
        get { shared?.clientPresentingViewController }
        set { shared?.clientPresentingViewController = newValue }
    }
}

// MARK: - Discovery
public extension IDKit {
    /**
     Performs a discovery to retrieve an OID configuration.
     - parameter issueUrl: The issuer url.
     - parameter completion: The block to be called when the discovery is completed either including the `authorizationEndpoint` and `tokenEndpoint` or an `error`.
     */
    static func discoverConfiguration(issuerUrl: String, _ completion: @escaping ((String?, String?, IDKitError?) -> Void)) {
        performDiscovery(issuerUrl: issuerUrl, completion)
    }
}

// MARK: - Token / Session handling
public extension IDKit {
    /**
     Performs an OID authorization request.
     - parameter completion: The block to be called when the request is completed including either a valid `accessToken` or an `error`.
     */
    static func authorize(_ completion: @escaping ((String?, IDKitError?) -> Void)) {
        shared?.performAuthorization(showSignInMask: false, completion)
    }

    /**
     Refreshes the current access token if needed.
     - parameter completion: The block to be called when the request is completed including either a new valid `accessToken` or an `error`.
     */
    static func refreshToken(_ completion: @escaping ((String?, IDKitError?) -> Void)) {
        shared?.performRefresh(completion)
    }

    /**
     Cancels the authorization flow and invokes the authorize completion block with a `cancelled` error.
     Has no effect when calling multiple times.
     - parameter completion: The block to be called when the cancellation is complete.
     */
    static func cancelAuthorizationFlow(_ completion: (() -> Void)? = nil) {
        shared?.authorizationFlow?.cancel(completion: completion)
    }

    /**
     Resets the current session.
     - parameter completion: The block to be called when the reset is completed.
     */
    static func resetSession(_ completion: (() -> Void)? = nil) {
        shared?.performReset(completion)
    }

    /**
     Checks the current authorization state. Returning `true` does not mean that the access is fresh - just that it was valid the last time it was used.
     - returns: The current state of the authorization.
     */
    static func isAuthorizationValid() -> Bool {
        shared?.session?.isAuthorized ?? false
    }

    /**
     Returns the latest received access token of the current session.
     - returns: The latest access token.
     */
    static func latestAccessToken() -> String? {
        shared?.session?.lastTokenResponse?.accessToken
    }
}

// MARK: - User
public extension IDKit {
    /**
    Retrieves the currently authorized user's information.
     - parameter completion: The block to be called when the request is completed including either a valid `userInfo` or an `error`.
     */
    static func userInfo(completion: @escaping (UserInfo?, IDKitError?) -> Void) {
        shared?.userInfo(completion: completion)
    }
}

// MARK: - PIN / Biometry
public extension IDKit {
    /**
     Checks if there is an active password set for the currently authenticated user.
     - parameter completion: The block to be called when the request is completed including either the `passwordStatus` or an `error`.
     */
    static func isPasswordSet(completion: @escaping (Result<Bool, IDKitError>) -> Void) {
        shared?.isPasswordSet(completion: completion)
    }

    /**
     Checks if there is an active PIN set for the currently authenticated user.
     - parameter completion: The block to be called when the request is completed including either the `pinStatus` or an `error`.
     */
    static func isPINSet(completion: @escaping (Result<Bool, IDKitError>) -> Void) {
        shared?.isPINSet(completion: completion)
    }

    /**
     Checks if there is an active PIN or password set for the currently authenticated user.
     - parameter completion: The block to be called when the request is completed including either the `pinOrPasswordStatus` or an `error`.
     */
    static func isPINOrPasswordSet(completion: @escaping (Result<Bool, IDKitError>) -> Void) {
        shared?.isPINOrPasswordSet(completion: completion)
    }

    /**
     Sets or updates the user's PIN.
     - parameter pin: The PIN to be set.
     - parameter password: The password that needs to be provided to successfully set or update the PIN.
     - parameter completion:
     The block to be called when the request is completed
     including either the information if the PIN has been set / updated `successfully` or an `error`.
     */
    static func setPIN(pin: String, password: String, completion: ((Result<Bool, IDKitError>) -> Void)? = nil) {
        shared?.setPIN(pin: pin, password: password) { completion?($0) }
    }

    /**
     Sets or updates the user's PIN.
     - parameter pin: The PIN to be set.
     - parameter otp: The OTP that needs to be provided to successfully set or update the PIN.
     - parameter completion:
     The block to be called when the request is completed
     including either the information if the PIN has been set / updated `successfully` or an `error`.
     */
    static func setPIN(pin: String, otp: String, completion: ((Result<Bool, IDKitError>) -> Void)? = nil) {
        shared?.setPIN(pin: pin, otp: otp) { completion?($0) }
    }

    /**
     Sets or updates the user's PIN.
     - parameter pin: The PIN to be set.
     - parameter otp: The OTP that additionally needs to be provided to successfully set or update the PIN.
     - parameter completion:
     The block to be called when the request is completed
     including either the information if the PIN has been set / updated `successfully` or an `error`.
     */
    static func setPINWithBiometry(pin: String, completion: ((Result<Bool, IDKitError>) -> Void)? = nil) {
        shared?.setPINWithBiometry(pin: pin) { completion?($0) }
    }

    /**
     Checks if biometric authentication is enabled for the current user.
     - returns: The information if biometric authentication is enabled.
     */
    static func isBiometricAuthenticationEnabled() -> Bool {
        shared?.isBiometricAuthenticationEnabled() ?? false
    }

    /**
     Enables biometric authentication for the current user using the PIN.
     - parameter pin: The PIN of the current user.
     - parameter completion:
     The block to be called when the request is completed
     including either the information if biometric authentication has been enabled `successfully` or an `error`.
     */
    static func enableBiometricAuthentication(pin: String, completion: ((Result<Bool, IDKitError>) -> Void)? = nil) {
        shared?.enableBiometricAuthentication(pin: pin, password: nil, otp: nil) { completion?($0) }
    }

    /**
     Enables biometric authentication for the current user using the account password.
     - parameter password: The password of the current user.
     - parameter completion:
     The block to be called when the request is completed
     including either the information if biometric authentication has been enabled `successfully` or an `error`.
     */
    static func enableBiometricAuthentication(password: String, completion: ((Result<Bool, IDKitError>) -> Void)? = nil) {
        shared?.enableBiometricAuthentication(pin: nil, password: password, otp: nil) { completion?($0) }
    }

    /**
     Enables biometric authentication for the current user using an OTP.
     - parameter otp: The OTP for the user.
     - parameter completion:
     The block to be called when the request is completed
     including either the information if biometric authentication has been enabled `successfully` or an `error`.
     */
    static func enableBiometricAuthentication(otp: String, completion: ((Result<Bool, IDKitError>) -> Void)? = nil) {
        shared?.enableBiometricAuthentication(pin: nil, password: nil, otp: otp) { completion?($0) }
    }

    /**
     Enables biometric authentication for the current user.

     This request will only succeed if called directly after an authorization.

     - parameter completion:
     The block to be called when the request is completed
     including either the information if biometric authentication has been enabled `successfully` or an `error`.
     */
    static func enableBiometricAuthentication(completion: ((Result<Bool, IDKitError>) -> Void)? = nil) {
        shared?.enableBiometricAuthentication(pin: nil, password: nil, otp: nil) { completion?($0) }
    }

    /**
     Disables biometric authentication for the current user.
     */
    static func disableBiometricAuthentication() {
        shared?.disableBiometricAuthentication()
    }

    /**
     Sends a mail to the user that provides an OTP.
     - parameter completion:
     The block to be called when the request is completed
     including either the information if the mail has been sent `successfully` or an `error`.
     */
    static func sendMailOTP(completion: ((Result<Bool, IDKitError>) -> Void)? = nil) {
        shared?.sendMailOTP { completion?($0) }
    }
}
