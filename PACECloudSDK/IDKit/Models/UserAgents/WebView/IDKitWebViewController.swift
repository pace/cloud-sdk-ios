//
//  IDKitWebViewController.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation
import UIKit

protocol IDKitWebViewControllerDelegate: AnyObject {
    func didReceiveCallbackURL(_ url: URL)
    func didFail(_ error: IDKitWebViewError)
}

class IDKitWebViewController: WebViewController {
    weak var userAgentDelegate: IDKitWebViewControllerDelegate?

    init(urlString: String, redirectScheme: String) {
        let webView = IDKitWebView(with: urlString, redirectScheme: redirectScheme, configurationType: .ephemeral)
        super.init(appUrl: urlString, hasNavigationBar: false, isModalInPresentation: false, webView: webView)
        webView.userAgentDelegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        if isBeingDismissed {
            userAgentDelegate?.didFail(.userCanceledAuthorizationFlow)
        }
    }
}

extension IDKitWebViewController: IDKitWebViewDelegate {
    func didReceiveCallbackURL(_ url: URL) {
        userAgentDelegate?.didReceiveCallbackURL(url)
    }

    func didFail(_ error: IDKitWebViewError) {
        userAgentDelegate?.didFail(error)
    }
}
