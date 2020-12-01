//
//  IDKit.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import AppAuth

protocol IDKitProtocol: AnyObject {
    static func setup(with configuration: IDKit.OIDConfiguration, cacheSession: Bool, presentingViewController: UIViewController?)
    static func swapPresentingViewController(with newViewController: UIViewController)

    static func authorize(_ completion: @escaping ((String?, IDKit.IDKitError?) -> Void))
    static func refreshToken(force: Bool, _ completion: @escaping ((String?, IDKit.IDKitError?) -> Void))
    static func cancelAuthorizationFlow(_ completion: (() -> Void)?)
    static func resetSession(_ completion: (() -> Void)?)
    static func isAuthorizationValid() -> Bool
}

public class IDKit: IDKitProtocol {
    static var shared: IDKit?

    var session: OIDAuthState?
    var authorizationFlow: OIDExternalUserAgentSession?

    var cacheSession: Bool

    var configuration: OIDConfiguration
    var presentingViewController: UIViewController?

    private init(with configuration: OIDConfiguration, cacheSession: Bool, presentingViewController: UIViewController?) {
        self.configuration = configuration
        self.cacheSession = cacheSession
        self.presentingViewController = presentingViewController

        guard cacheSession, let session = SessionCache.loadSession() else { return }

        self.session = session
    }

    /**
     Sets up IDKit with the passed configuration.
     - parameter configuration: The current `OIDConfiguration`.
     - parameter cacheSession: If set to `true` the session will be persisted by IDKit to improve the chance of not having to resign in again. Defaults to `true`.
     - parameter presentingViewControllerl: The view controller to present the authorization's view on.
     Can be passed at a later point in time.
     */
    public static func setup(with configuration: OIDConfiguration, cacheSession: Bool = true, presentingViewController: UIViewController? = nil) {
        shared = nil
        shared = IDKit(with: configuration, cacheSession: cacheSession, presentingViewController: presentingViewController)
    }

    /**
     Swaps the current presenting view controller with a new one
     without having to call `setup(with configuration: OIDConfiguration, presentingViewController: UIViewController? = nil)` again.
     - parameter newViewController: The new presenting view controller.
     */
    public static func swapPresentingViewController(with newViewController: UIViewController) {
        shared?.presentingViewController = newViewController
    }
}

// MARK: - Discovery
public extension IDKit {
    /**
     Performs a discovery to retrieve an OID configuration.
     - parameter issueUrl: The issuer url.
     - parameter completion: The block to be called when the discovery is complete either including the `authorizationEndpoint` and `tokenEndpoint` or an `error`.
     */
    static func discoverConfiguration(issuerUrl: String, _ completion: @escaping ((String?, String?, IDKitError?) -> Void)) {
        performDiscovery(issuerUrl: issuerUrl, completion)
    }
}

// MARK: Token / Session handling
public extension IDKit {
    /**
     Performs an OID authorization request.
     - parameter completion: The block to be called when the request is complete including either a valid `accessToken` or an `error`.
     */
    static func authorize(_ completion: @escaping ((String?, IDKitError?) -> Void)) {
        shared?.performAuthorization(completion)
    }

    /**
     Refreshes the current access token if needed.
     - parameter force: Forces a refresh even if the current accessToken is still valid. Defaults to `false`.
     - parameter completion: The block to be called when the request is complete including either a new valid `accessToken` or an `error`.
     */
    static func refreshToken(force: Bool = false, _ completion: @escaping ((String?, IDKitError?) -> Void)) {
        shared?.performRefresh(force: force, completion)
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
     - parameter completion: The block to be called when the reset is complete.
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

// MARK: User
public extension IDKit {
    /**
    Retrieves the currently authorized user's information.
     - parameter completion: The block to be called when the request is complete including either valid `userInfo` or an `error`.
     */
    static func userInfo(completion: @escaping (UserInfo?, IDKitError?) -> Void) {
        shared?.userInfo(completion: completion)
    }
}
