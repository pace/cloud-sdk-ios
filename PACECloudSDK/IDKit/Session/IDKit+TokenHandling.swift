//
//  IDKit+TokenHandling.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import AppAuth

// MARK: - Authorization
extension IDKit {
    func performAuthorization(showSignInMask: Bool, _ completion: @escaping ((String?, IDKitError?) -> Void)) {
        guard let authorizationEndpointUrl = URL(string: configuration.authorizationEndpoint) else {
            completion(nil, IDKitError.invalidAuthorizationEndpoint)
            return
        }

        guard let tokenEndpointUrl = URL(string: configuration.tokenEndpoint) else {
            completion(nil, IDKitError.invalidTokenEndpoint)
            return
        }

        guard let redirectUrl = URL(string: configuration.redirectUrl) else {
            completion(nil, IDKitError.invalidRedirectUrl)
            return
        }

        let presentingViewController: UIViewController? = {
            if showSignInMask {
                presentSignInWindow()
                return paceIDSignInWindow?.rootViewController
            } else {
                return clientPresentingViewController
            }
        }()

        guard let viewController = presentingViewController else {
            completion(nil, IDKitError.invalidPresentingViewController)
            return
        }

        let request = buildAuthorizationRequest(authorizationEndpoint: authorizationEndpointUrl, tokenEndpoint: tokenEndpointUrl, redirectUrl: redirectUrl)

        // Try to refresh token from last session cache
        if cacheSession, session != nil {
            IDKitLogger.i("Trying to refresh session...")
            performRefresh(completion)
            return
        }

        startAuthorizationFlow(with: request, presentingViewController: viewController, completion)
    }

    private func buildAuthorizationRequest(authorizationEndpoint: URL, tokenEndpoint: URL, redirectUrl: URL) -> OIDAuthorizationRequest {
        let oidConfiguration = OIDServiceConfiguration(authorizationEndpoint: authorizationEndpoint,
                                                       tokenEndpoint: tokenEndpoint)

        let request = OIDAuthorizationRequest(configuration: oidConfiguration,
                                              clientId: configuration.clientId,
                                              clientSecret: configuration.clientSecret,
                                              scopes: configuration.scopes,
                                              redirectURL: redirectUrl,
                                              responseType: configuration.responseType,
                                              additionalParameters: configuration.additionalParameters)
        return request
    }

    private func startAuthorizationFlow(with request: OIDAuthorizationRequest,
                                        presentingViewController: UIViewController,
                                        _ completion: @escaping ((String?, IDKitError?) -> Void)) {
        let callback: OIDAuthStateAuthorizationCallback = { [weak self] authState, error in
            defer {
                self?.paceIDSignInWindow = nil
            }

            if let error = error {
                self?.performReset { completion(nil, IDKitError.other(error)) }
                return
            }

            guard let session = authState else {
                self?.performReset { completion(nil, IDKitError.failedRetrievingSessionWhileAuthorizing) }
                return
            }

            // Persist current session
            if self?.cacheSession == true {
                SessionCache.persistSession(session)
            }

            self?.session = authState
            let accessToken = session.lastTokenResponse?.accessToken
            completion(accessToken, nil)
            IDKitLogger.i("Authorization successful")
        }

        var userAgent: OIDExternalUserAgent?
        if #available(iOS 13.0, *) {
            userAgent = IDKitUserAgent(with: presentingViewController) // Hide ASWebAuthenticationSession popup
        }

        let authorizationFlow: OIDExternalUserAgentSession?

        if let userAgent = userAgent {
            authorizationFlow = OIDAuthState.authState(byPresenting: request, externalUserAgent: userAgent, callback: callback)
        } else {
            authorizationFlow = OIDAuthState.authState(byPresenting: request, presenting: presentingViewController, callback: callback)
        }

        self.authorizationFlow = authorizationFlow
    }
}

// MARK: - Refresh
extension IDKit {
    func performRefresh(_ completion: @escaping ((String?, IDKitError?) -> Void)) {
        guard let session = session else {
            performReset { completion(nil, IDKitError.invalidSession) }
            return
        }

        session.setNeedsTokenRefresh()
        session.performAction(freshTokens: { [weak self] accessToken, _, error in
            guard let error = error else {
                completion(accessToken, nil)
                IDKitLogger.i("Refresh successful")
                return
            }

            if session.isAuthorized {
                // e.g network error
                completion(nil, IDKitError.other(error))
            } else {
                self?.performReset { completion(nil, IDKitError.failedTokenRefresh(error)) }
            }
        })
    }
}

// MARK: - Reset
extension IDKit {
    func performReset(_ completion: (() -> Void)? = nil) {
        disableBiometricAuthentication()

        session = nil
        SessionCache.reset()

        guard let authorizationFlow = authorizationFlow else {
            completion?()
            return
        }

        authorizationFlow.cancel { [weak self] in
            self?.authorizationFlow = nil
        }

        completion?()
    }
}
