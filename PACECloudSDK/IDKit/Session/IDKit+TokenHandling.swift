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
                self?.performReset { _ in completion(.failure(error)) }
                return
            }

            guard let session = authState else {
                self?.performReset { _ in completion(.failure(.failedRetrievingSessionWhileAuthorizing)) }
                return
            }

            // Persist current session
            SessionCache.persistSession(session, for: PACECloudSDK.shared.environment)

            self?.session = authState
            let accessToken = session.lastTokenResponse?.accessToken
            self?.handleUpdatedAccessToken(with: accessToken)

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

    func handleUpdatedAccessToken(with token: String?) {
        API.accessToken = token

        guard let token = token,
              let userId = TokenValidator(accessToken: token).jwtValue(for: IDKitConstants.jwtSubjectKey) as? String else {
            SDKUserDefaults.deleteUserScopedData()
            SDKKeychain.deleteUserScopedData()
            return
        }

        SDKUserDefaults.setUserId(userId)
        SDKKeychain.setUserId(userId)
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
                self?.handleUpdatedAccessToken(with: accessToken)
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
                self?.performReset { _ in completion(.failure(.failedTokenRefresh(error))) }
            }
        })
    }
}

// MARK: - Reset
extension IDKit {
    func performReset(_ completion: ((Result<Void, IDKitError>) -> Void)? = nil) {
        endSession { [weak self] result in
            self?.delegate?.willResetSession()

            self?.disableBiometricAuthentication()

            self?.handleUpdatedAccessToken(with: nil)

            self?.session = nil
            SessionCache.reset(for: PACECloudSDK.shared.environment)

            guard let authorizationFlow = self?.authorizationFlow else {
                completion?(result)
                return
            }

            authorizationFlow.cancel { [weak self] in
                self?.authorizationFlow = nil
            }

            completion?(result)
        }
    }
}

// MARK: - End session
extension IDKit {
    func endSession(_ completion: ((Result<Void, IDKitError>) -> Void)? = nil) {
        guard let accessToken = IDKit.latestAccessToken(),
              let refreshToken = session?.lastTokenResponse?.refreshToken,
              let sessionEndPoint = configuration.endSessionEndpoint,
              let url = URL(string: sessionEndPoint) else {
                  IDKitLogger.w("End session failed: Couldn't retrieve accessToken, refreshToken or sessionEndPoint is invalid")
                  DispatchQueue.main.async {
                      completion?(.failure(.failedEndSession("End session failed: Couldn't retrieve accessToken, refreshToken or sessionEndPoint is invalid")))
                  }
                  return
              }

        let headers = ["Authorization": "Bearer \(accessToken)", "Content-Type": "application/x-www-form-urlencoded"]
        var components = URLComponents()
        components.queryItems = [.init(name: "client_id", value: configuration.clientId), .init(name: "refresh_token", value: refreshToken)]

        var request = URLRequest(url: url)
        headers.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
        request.httpMethod = "POST"
        request.httpBody = components.query?.data(using: .utf8)

        URLSession.shared.dataTask(with: request) { _, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    IDKitLogger.w("End session failed with error: \(error.localizedDescription)")
                    completion?(.failure(.failedEndSession(error.localizedDescription)))
                } else {
                    completion?(.success(()))
                }
            }
        }.resume()
    }
}
