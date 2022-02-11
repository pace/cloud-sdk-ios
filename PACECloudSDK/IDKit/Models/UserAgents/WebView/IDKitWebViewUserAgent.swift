//
//  IDKitWebViewUserAgent.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import AppAuth
import UIKit
import WebKit

class IDKitWebViewUserAgent: NSObject, OIDExternalUserAgent {
    private let presentingViewController: UIViewController
    private var externalUserAgentFlowInProgress: Bool = false
    private var webViewController: IDKitWebViewController?

    private weak var session: OIDExternalUserAgentSession?

    init(with presentingViewController: UIViewController) {
        self.presentingViewController = presentingViewController
        super.init()
    }

    func present(_ request: OIDExternalUserAgentRequest, session: OIDExternalUserAgentSession) -> Bool {
        guard let requestURL = request.externalUserAgentRequestURL(), let redirectScheme = request.redirectScheme(), !externalUserAgentFlowInProgress else { return false }

        self.externalUserAgentFlowInProgress = true
        self.session = session

        let webViewController = IDKitWebViewController(urlString: requestURL.absoluteString, redirectScheme: redirectScheme)
        webViewController.delegate = self
        webViewController.userAgentDelegate = self

        self.webViewController = webViewController

        if presentingViewController.view.window == nil {
            UIApplication.shared.keyWindow?.rootViewController?.present(webViewController, animated: true) // Correctly presents login screen for SwiftUI views
        } else {
            presentingViewController.present(webViewController, animated: true)
        }

        return true
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

    func reset() {
        session = nil

        webViewController?.dismiss(animated: true) { [weak self] in
            self?.webViewController = nil
        }

        externalUserAgentFlowInProgress = false
    }

    private func resumeAuthorizationFlow(with url: URL) {
        session?.resumeExternalUserAgentFlow(with: url)
    }

    private func cancelAuthorizationFlow(with error: IDKitWebViewError) {
        session?.failExternalUserAgentFlowWithError(IDKitWebViewError.userCanceledAuthorizationFlow)
        reset()
    }
}

extension IDKitWebViewUserAgent: IDKitWebViewControllerDelegate {
    func didReceiveCallbackURL(_ url: URL) {
        resumeAuthorizationFlow(with: url)
    }

    func didFail(_ error: IDKitWebViewError) {
        cancelAuthorizationFlow(with: error)
    }
}

extension IDKitWebViewUserAgent: WebViewControllerDelegate {
    func dismiss(webViewController: WebViewController) {
        cancelAuthorizationFlow(with: .userCanceledAuthorizationFlow)
    }
}
