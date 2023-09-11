//
//  IDKitUserAgent.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import AppAuth
import AuthenticationServices

class IDKitUserAgent: NSObject, OIDExternalUserAgent {
    private let presentingViewController: UIViewController
    private var externalUserAgentFlowInProgress: Bool = false
    private var authenticationViewController: ASWebAuthenticationSession?

    private weak var session: OIDExternalUserAgentSession?

    init(with presentingViewController: UIViewController) {
        self.presentingViewController = presentingViewController
        super.init()
    }

    func present(_ request: OIDExternalUserAgentRequest, session: OIDExternalUserAgentSession) -> Bool {
        guard let requestURL = request.externalUserAgentRequestURL(), !externalUserAgentFlowInProgress else { return false }

        self.externalUserAgentFlowInProgress = true
        self.session = session

        let redirectScheme = request.redirectScheme()
        self.authenticationViewController = ASWebAuthenticationSession(url: requestURL, callbackURLScheme: redirectScheme) { callbackURL, error in
            self.authenticationViewController = nil

            if let url = callbackURL {
                self.session?.resumeExternalUserAgentFlow(with: url)
            } else {
                let webAuthenticationError = OIDErrorUtilities.error(with: OIDErrorCode.userCanceledAuthorizationFlow,
                                                                     underlyingError: error,
                                                                     description: nil)
                self.session?.failExternalUserAgentFlowWithError(webAuthenticationError)
            }
        }

        authenticationViewController?.presentationContextProvider = self
        authenticationViewController?.prefersEphemeralWebBrowserSession = true // allows for private browsing, hides the login prompt/popup

        return authenticationViewController?.start() ?? false
    }

    func dismiss(animated: Bool, completion: @escaping () -> Void) {
        // Ignore this call if there is no authorization flow in progress.
        guard externalUserAgentFlowInProgress else {
            completion()
            return
        }

        reset()

        completion()
    }

    private func reset() {
        session = nil

        authenticationViewController?.cancel()
        authenticationViewController = nil

        externalUserAgentFlowInProgress = false
    }
}

extension IDKitUserAgent: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        presentingViewController.view.window ?? UIApplication.shared.keyWindow ?? UIWindow()
    }
}
