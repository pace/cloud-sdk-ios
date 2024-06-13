//
//  IDKit.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import AppAuth

// swiftlint:disable file_length
public class IDKit {
    static var shared: IDKit? {
        PACECloudSDK.shared.warningsHandler?.logSDKWarningsIfNeeded()
        return sharedInstance
    }

    static var isSetUp: Bool {
        sharedInstance != nil
    }

    static var defaultScopes: [String] {
        [OIDScopeOpenID]
    }

    private static var sharedInstance: IDKit?

    weak var delegate: IDKitDelegate?

    var session: OIDAuthState?
    var authorizationFlow: OIDExternalUserAgentSession?
    var configuration: OIDConfiguration
    let userAgentType: UserAgentType

    var clientPresentingViewController: UIViewController?
    var paceIDSignInWindow: PaceIDSignInWindow?

    private init(with configuration: OIDConfiguration, userAgentType: UserAgentType) {
        self.configuration = configuration
        self.userAgentType = userAgentType

        guard let session = SessionCache.loadSession(for: PACECloudSDK.shared.environment) else { return }
        self.session = session

        handleUpdatedAccessToken(with: session.lastTokenResponse?.accessToken)
    }

    private static func setup(with configuration: OIDConfiguration, userAgentType: UserAgentType) {
        sharedInstance = IDKit(with: configuration, userAgentType: userAgentType)
    }

    static func determineOIDConfiguration(with customOIDConfig: OIDConfiguration?, userAgentType: UserAgentType) {
        if let customOIDConfig = customOIDConfig {
            setup(with: customOIDConfig, userAgentType: userAgentType)
        } else if let oidConfigClientId = PACECloudSDK.shared.clientId,
                  let oidConfigRedirectUri = Bundle.main.oidConfigRedirectUri {
            let defaultOIDConfiguration = OIDConfiguration.defaultOIDConfiguration(clientId: oidConfigClientId,
                                                                                   redirectUri: oidConfigRedirectUri,
                                                                                   idpHint: Bundle.main.oidConfigIdpHint)
            setup(with: defaultOIDConfiguration, userAgentType: userAgentType)
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

    /**
     Checks if a session object is available.

     If this statement returns `true`, it does not necessarily mean the access token is valid or even non-nil.
     It just means there generally is a session object available for the current user 
     even though the access might not be fresh.

     Can be used to check whether a user is supposed to be authenticated.

     To check the state of the latest access token, use `IDKit.latestAccessToken()`.
     
     - returns: Whether a session object exists.
     */
    static var isSessionAvailable: Bool {
        shared?.session != nil
    }
}

// MARK: - Discovery
public extension IDKit {
    /**
     Performs a discovery to retrieve an OID configuration.
     - parameter issueUrl: The issuer url.
     - parameter completion: The block to be called when the discovery is completed either including the `authorizationEndpoint` and `tokenEndpoint` or an `error`.
     */
    static func discoverConfiguration(issuerUrl: String, _ completion: @escaping (Result<OIDConfiguration.Response, IDKitError>) -> Void) {
        performDiscovery(issuerUrl: issuerUrl, completion)
    }
}

// MARK: - Token / Session handling
public extension IDKit {
    /**
     Performs an OID authorization request.
     - parameter completion: The block to be called when the request is completed including either a valid `accessToken` or an `error`.
     */
    static func authorize(_ completion: @escaping (Result<String?, IDKitError>) -> Void) {
        shared?.performAuthorization(showSignInMask: false, completion)
    }

    /**
     Refreshes the current access token if needed.
     - parameter completion: The block to be called when the request is completed including either a new valid `accessToken` or an `error`.
     */
    static func refreshToken(_ completion: @escaping (Result<String?, IDKitError>) -> Void) {
        shared?.performRefresh(completion)
    }

    /**
     Cancels the authorization flow and invokes the authorize completion block with a `cancelled` error.
     Has no effect when calling multiple times.
     - parameter completion: The block to be called when the cancellation is complete.
     */
    static func cancelAuthorizationFlow(_ completion: (() -> Void)? = nil) {
        shared?.performCancelAuthorizationFlow(completion: completion)
    }

    /**
     Resets the current session.
     - parameter completion: The block to be called when the reset is completed including either success or an `error`.
     */
    static func resetSession(_ completion: ((Result<Void, IDKit.IDKitError>) -> Void)? = nil) {
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
    static func userInfo(completion: @escaping (Result<UserInfo, IDKitError>) -> Void) {
        shared?.userInfo(completion: completion)
    }

    /**
     Fetches a list of valid payment methods for the current user.
     - parameter completion: The block to be called when the request is completed including either the `paymentMethods` or an `error`.
     */
    static func paymentMethods(completion: @escaping (Result<PCPayPaymentMethods, IDKitError>) -> Void) {
        shared?.paymentMethods(completion: completion)
    }

    /**
     Fetches a list of transactions for the current user sorted in descending order by creation date.
     - parameter completion: The block to be called when the request is completed including either the `transactions` or an `error`.
     */
    static func transactions(completion: @escaping (Result<PCPayTransactions, IDKitError>) -> Void) {
        shared?.transactions(completion: completion)
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
     Checks if the given PIN is valid.

     The following rules apply to verify the PIN:
     - Must be 4 digits long
     - Must use 3 different digits
     - Must not be a numerical series (e.g. 1234, 4321, ...)

     - parameter pin: The PIN to be checked.
     - returns: `true` if the PIN is valid, `false` otherwise.
     */
    static func isPINValid(pin: String) -> Bool {
        shared?.isPINValid(pin: pin) ?? false
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
     Evaluates the use of biometric authentication.

     This method asynchronously evaluates the biometric authentication policy. It may involve prompting the user for interaction.

     - parameter completion:
     The block to be called when the evaluation is completed
     including either the information if the biometry policy has been evaluated `successfully` or an `error`.
     */
    static func evaluateBiometryPolicy(completion: @escaping (Result<Bool, IDKitError>) -> Void) {
        shared?.evaluateBiometryPolicy(completion: completion)
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

    /**
     Generates an OTP by using biometry evaluation.
     - parameter completion:
     The block to be called when the request is completed
     including either the generated `OTP` or an `error`.
     */
    static func generateOTPWithBiometry(completion: @escaping (Result<String, IDKitError>) -> Void) {
        shared?.otpWithBiometry(completion: completion)
    }

    /**
     Generates an OTP by using the user's PACE PIN.
     - parameter pin: The user's PACE PIN.
     - parameter completion:
     The block to be called when the request is completed
     including either the generated `OTP` or an `error`.
     */
    static func generateOTP(pin: String, completion: @escaping (Result<String, IDKitError>) -> Void) {
        shared?.otp(password: nil, pin: pin, completion: completion)
    }

    /**
     Generates an OTP by using the user's PACE ID password.
     - parameter password: The user's PACE ID password.
     - parameter completion:
     The block to be called when the request is completed
     including either the generated `OTP` or an `error`.
     */
    static func generateOTP(password: String, completion: @escaping (Result<String, IDKitError>) -> Void) {
        shared?.otp(password: password, pin: nil, completion: completion)
    }

    /**
     Returns data in the keychain stored with the specified key.
     - parameter key: The key the data was stored with.
     - returns: The stored keychain data or `nil` if non was found.
     */
    static func getKeychainSecretData(with key: String) -> Data? {
        SDKKeychain.data(for: key, isUserSensitiveData: true)
    }
}

// MARK: - Additional query parameters
extension IDKit {
    static func handleAdditionalQueryParams(_ params: Set<URLQueryItem>) {
        let dict = Dictionary(uniqueKeysWithValues: params.map { ($0.name, $0.value ?? "") })
        IDKit.OIDConfiguration.appendAdditionalParameters(dict)
    }
}
