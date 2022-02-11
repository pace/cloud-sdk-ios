//
//  IDKitWebView.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation
import WebKit

protocol IDKitWebViewDelegate: AnyObject {
    func didReceiveCallbackURL(_ url: URL)
    func didFail(_ error: IDKitWebViewError)
}

enum IDKitWebViewError: Error, CustomStringConvertible {
    case failedNavigationAction
    case userCanceledAuthorizationFlow

    var description: String {
        switch self {
        case .failedNavigationAction:
            return "A webview navigation action has failed."

        case .userCanceledAuthorizationFlow:
            return "The user has canceled the authorization process."
        }
    }
}

class IDKitWebView: WebView {
    weak var userAgentDelegate: IDKitWebViewDelegate?

    private let redirectScheme: String

    init(with url: String?, redirectScheme: String, configurationType: WebViewConfigurationType = .persistCookies) {
        self.redirectScheme = redirectScheme
        super.init(with: url, configurationType: configurationType)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension IDKitWebView {
    override func webView(_ webView: WKWebView,
                          decidePolicyFor navigationAction: WKNavigationAction,
                          decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            userAgentDelegate?.didFail(.failedNavigationAction)
            decisionHandler(.cancel)
            return
        }

        if url.scheme == redirectScheme {
            userAgentDelegate?.didReceiveCallbackURL(url.absoluteURL)
            decisionHandler(.allow)
            return
        }

        // We only want http & https to be handled by the webview itself
        guard url.isFileURL || url.scheme == "http" || url.scheme == "https" else {
            UIApplication.shared.open(url)
            decisionHandler(.cancel)
            return
        }

        decisionHandler(.allow)
    }
}
