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
            IDKitLogger.d("Trying to refresh session...")
            performRefresh(completion)
            return
        }

        startAuthorizationFlow(with: request, presentingViewController: viewController, completion)
    }

    func performCancelAuthorizationFlow(completion: (() -> Void)?) {
        authorizationFlow?.cancel(completion: completion)
    }

    private func buildAuthorizationRequest(authorizationEndpoint: URL, tokenEndpoint: URL, redirectUrl: URL) -> OIDAuthorizationRequest {
        let oidConfiguration = OIDServiceConfiguration(authorizationEndpoint: authorizationEndpoint,
                                                       tokenEndpoint: tokenEndpoint)

        let request = OIDAuthorizationRequest(configuration: oidConfiguration,
                                              clientId: configuration.clientId,
                                              clientSecret: configuration.clientSecret,
                                              scopes: (configuration.scopes ?? []) + IDKit.defaultScopes,
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
            self?.session = authState
            let accessToken = session.lastTokenResponse?.accessToken

            if let exchangeConfig = self?.configuration.tokenExchangeConfig, let token = accessToken {
                self?.performTokenExchange(with: token, configuration: exchangeConfig) { newApiToken in
                    guard let newApiToken else {
                        self?.performReset { _ in completion(.failure(.tokenExchangeFailed)) }
                        return
                    }
                    self?.finalizeAuthorization(session: session, accessToken: accessToken, exchangeToken: newApiToken, completion: completion)
                }
            } else {
                self?.finalizeAuthorization(session: session, accessToken: accessToken, exchangeToken: nil, completion: completion)
            }
        }

        var userAgent: OIDExternalUserAgent?

        switch userAgentType {
        case .integrated:
            userAgent = IDKitWebViewUserAgent(with: presentingViewController)

        case .external:
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
    
    private func finalizeAuthorization(session: OIDAuthState,
                                       accessToken: String?,
                                       exchangeToken: String?,
                                       completion: @escaping (Result<String?, IDKitError>) -> Void) {
        handleUpdatedAccessToken(with: accessToken, exchangeToken: exchangeToken)
        SessionCache.persistSession(session, for: PACECloudSDK.shared.environment)
        completion(.success(accessToken))
        IDKitLogger.i("Authorization successful")
    }


    func performTokenExchange(with token: String, configuration: TokenExchangeConfiguration, completion: @escaping ((String?) -> Void)) {
        var request = URLRequest(url: URL(string: Settings.shared.tokenEndpointUrl)!) // swiftlint:disable:this force_unwrapping
        request.httpMethod = "POST"
        let params = [
            "grant_type": "urn:ietf:params:oauth:grant-type:token-exchange",
            "client_id": configuration.exchangeClientID,
            "subject_issuer": configuration.exchangeIssuerID,
            "client_secret": configuration.exchangeClientSecret,
            "subject_token": token,
            "subject_token_type": "urn:ietf:params:oauth:token-type:access_token"
        ]
        request.httpBody = params
            .map { "\($0)=\($1.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)" } // swiftlint:disable:this force_unwrapping
            .joined(separator: "&")
            .data(using: .utf8)

        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, _, error in
            var returnToken: String?
            if let data = data, let jsonString = data.prettyPrintedJSONString, let exchangeToken = jsonString["access_token"] as? String {
                returnToken = exchangeToken
                IDKitLogger.i("[TokenExchange] Token exchange successful")
            } else {
                IDKitLogger.e("[TokenExchange] Error while token exchange \(String(describing: error))")
            }
            completion(returnToken)
        })
        task.resume()
    }

    func handleUpdatedAccessToken(with token: String?, exchangeToken: String?) {
        if let exchangeToken = exchangeToken {
            API.accessToken = exchangeToken
        } else {
            API.accessToken = token
        }
        if let token = token,
           let userId = TokenValidator(accessToken: token).jwtValue(for: IDKitConstants.jwtSubjectKey) as? String {
            SDKUserDefaults.setUserId(userId)
            SDKKeychain.setUserId(userId)
        } else {
            SDKUserDefaults.deleteUserScopedData()
            SDKKeychain.deleteUserScopedData()
        }
        delegate?.accessTokenChanged(API.accessToken)

    }
}

// MARK: - Refresh
extension IDKit {
    func performRefresh(_ completion: @escaping (Result<String?, IDKitError>) -> Void) {
        idKitQueue.async { [weak self] in
            guard let self else {
                completion(.failure(.internalError))
                IDKitLogger.e("[TokenRefresh] Self not available")
                return
            }
            refreshCompletionHandlers.append(completion)

            guard !isRefreshing else { return }

            isRefreshing = true

            performActualRefresh { [weak self] result in
                self?.idKitQueue.async {
                    self?.refreshCompletionHandlers.forEach { $0(result) }
                    self?.refreshCompletionHandlers.removeAll()
                    self?.isRefreshing = false
                }
            }
        }
    }

    private func performActualRefresh(currentRetryCount: Int = 0, _ completion: @escaping (Result<String?, IDKitError>) -> Void) {
        guard let session = session else {
            completion(.failure(.invalidSession))
            return
        }

        session.setNeedsTokenRefresh()
        session.performAction(freshTokens: { [weak self] accessToken, _, error in
            guard let self else {
                completion(.failure(.internalError))
                IDKitLogger.e("[TokenRefresh] Self not available")
                return
            }

            guard let error = error else {
                if let exchangeConfig = self.configuration.tokenExchangeConfig, let token = accessToken {
                    self.performTokenExchange(with: token, configuration: exchangeConfig) { newApiToken in
                        if newApiToken == nil {
                            completion(.failure(.tokenExchangeFailed))
                            return
                        } else {
                            completion(.success(newApiToken))
                        }
                        self.handleUpdatedAccessToken(with: accessToken, exchangeToken: newApiToken)
                        IDKitLogger.i("[TokenRefresh] Refresh successful")

                        // Update persisted session
                        SessionCache.persistSession(session, for: PACECloudSDK.shared.environment)
                        return
                    }
                } else {
                    completion(.success(accessToken))
                    self.handleUpdatedAccessToken(with: accessToken, exchangeToken: nil)
                    IDKitLogger.i("[TokenRefresh] Refresh successful")

                    // Update persisted session
                    SessionCache.persistSession(session, for: PACECloudSDK.shared.environment)
                }
                return
            }

            let newRetryCount = currentRetryCount + 1

            if session.isAuthorized {
                switch (error as NSError).code {
                case NSURLErrorTimedOut,
                    OIDErrorCode.networkError.rawValue:
                    IDKitLogger.d("[TokenRefresh] Failed with network error, retrying again.")

                    let requestDelay = nextExponentialBackoffRequestDelayWithJitter(currentRetryCount: newRetryCount)

                    idKitQueue.asyncAfter(deadline: .now() + .seconds(requestDelay)) { [weak self] in
                        self?.performActualRefresh(currentRetryCount: newRetryCount, completion)
                    }

                case OIDErrorCode.serverError.rawValue:
                    IDKitLogger.d("[TokenRefresh] Failed with server error, retrying again.")
                    let requestDelay = nextExponentialBackoffRequestDelayWithJitter(currentRetryCount: newRetryCount, delayLowerBound: 60, delayUpperBound: 5 * 60)

                    idKitQueue.asyncAfter(deadline: .now() + .seconds(requestDelay)) { [weak self] in
                        self?.performActualRefresh(currentRetryCount: newRetryCount, completion)
                    }

                default:
                    completion(.failure(.other(error)))
                }
            } else {
                performReset { _ in completion(.failure(.failedTokenRefresh(error))) }
            }
        })
    }
}

// MARK: - Exponential backoff
extension IDKit {
    /**
     Returns the number of seconds an API request should be delayed before the next retry is executed.

     It calculates the number of seconds based on an exponential backoff algorithm with jitter.

     - parameter currentRetryCount: The current number of retries for a specific request.
     - parameter delayUpperBound: The maximum number of seconds a request should be delayed. Defaults to `60`.
     - returns: The request delay in seconds.
     */
    func nextExponentialBackoffRequestDelayWithJitter(currentRetryCount: Int, delayLowerBound: Int = 0, delayUpperBound: Int = 60) -> Int {
        let nextDelayIteration = NSDecimalNumber(decimal: pow(2, currentRetryCount - 1))
        let max = min(Int(truncating: nextDelayIteration), delayUpperBound)

        return Int.random(in: 0...max)
    }
}

// MARK: - Reset
extension IDKit {
    func performReset(_ completion: ((Result<Void, IDKitError>) -> Void)? = nil) {
        endSession { [weak self] result in
            self?.delegate?.willResetSession()

            self?.disableBiometricAuthentication()

            self?.handleUpdatedAccessToken(with: nil, exchangeToken: nil)

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

    private func endSession(_ completion: ((Result<Void, IDKitError>) -> Void)? = nil) {
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

        var request = URLRequest.defaultURLRequest(url: url)
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

// MARK: - Concurrency

@MainActor
extension IDKit {
    func performAuthorization(showSignInMask: Bool) async -> Result<String?, IDKitError> {
        await withCheckedContinuation { [weak self] continuation in
            self?.performAuthorization(showSignInMask: showSignInMask) { result in
                continuation.resume(returning: result)
            }
        }
    }

    func performCancelAuthorizationFlow() async {
        await withCheckedContinuation { [weak self] continuation in
            self?.performCancelAuthorizationFlow {
                continuation.resume()
            }
        }
    }

    func performRefresh() async -> Result<String?, IDKitError> {
        await withCheckedContinuation { [weak self] continuation in
            self?.performRefresh { result in
                continuation.resume(returning: result)
            }
        }
    }

    func performReset() async -> Result<Void, IDKitError> {
        await withCheckedContinuation { [weak self] continuation in
            self?.performReset { result in
                continuation.resume(returning: result)
            }
        }
    }
}
