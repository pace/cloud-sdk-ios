//
//  IDKit+TokenHandling.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import AppAuth

// MARK: - Authorization
extension IDKit {
    func performAuthorization(showSignInMask: Bool, _ completion: @escaping (Result<String?, IDKitError>) -> Void) {
        guard let authorizationEndpointUrl = URL(string: configuration.authorizationEndpoint) else {
            completion(.failure(.invalidAuthorizationEndpoint))
            return
        }

        guard let tokenEndpointUrl = URL(string: configuration.tokenEndpoint) else {
            completion(.failure(.invalidTokenEndpoint))
            return
        }

        guard let redirectUrl = URL(string: configuration.redirectUri) else {
            completion(.failure(.invalidRedirectUrl))
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
            completion(.failure(.invalidPresentingViewController))
            return
        }

        let request = buildAuthorizationRequest(authorizationEndpoint: authorizationEndpointUrl, tokenEndpoint: tokenEndpointUrl, redirectUrl: redirectUrl)

        // Try to refresh token from last session cache
        if session != nil {
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
                                        _ completion: @escaping (Result<String?, IDKitError>) -> Void) {
        let callback: OIDAuthStateAuthorizationCallback = { [weak self] authState, error in
            defer {
                self?.paceIDSignInWindow = nil
            }

            if let error = error {
                let error: IDKitError = (error as NSError).code == OIDErrorCode.userCanceledAuthorizationFlow.rawValue ? .authorizationCanceled : .other(error)
                self?.performReset { completion(.failure(error)) }
                return
            }

            guard let session = authState else {
                self?.performReset { completion(.failure(.failedRetrievingSessionWhileAuthorizing)) }
                return
            }

            // Persist current session
            SessionCache.persistSession(session)

            self?.session = authState
            let accessToken = session.lastTokenResponse?.accessToken
            API.accessToken = accessToken

            completion(.success(accessToken))
            IDKitLogger.i("Authorization successful")
        }

        var userAgent: OIDExternalUserAgent?

        switch userAgentType {
        case .integrated:
            userAgent = IDKitWebViewUserAgent(with: presentingViewController)

        case .external:
            guard #available(iOS 13.0, *) else { break }
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
    func performRefresh(_ completion: @escaping (Result<String?, IDKitError>) -> Void) {
        guard let session = session else {
            completion(.failure(.invalidSession))
            return
        }

        session.setNeedsTokenRefresh()
        session.performAction(freshTokens: { [weak self] accessToken, _, error in
            guard let error = error else {
                API.accessToken = accessToken
                completion(.success(accessToken))
                IDKitLogger.i("Refresh successful")
                return
            }

            if session.isAuthorized {
                if (error as NSError).code == OIDErrorCode.serverError.rawValue {
                    completion(.failure(.internalError))
                } else {
                    // e.g network error
                    completion(.failure(.other(error)))
                }
            } else {
                self?.performReset { completion(.failure(.failedTokenRefresh(error))) }
            }
        })
    }
}

// MARK: - Reset
extension IDKit {
    func performReset(_ completion: (() -> Void)? = nil) {
        delegate?.willResetSession()

        disableBiometricAuthentication()

        session = nil
        SessionCache.reset()
        API.accessToken = nil

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
