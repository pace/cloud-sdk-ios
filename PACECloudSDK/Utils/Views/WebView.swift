//
//  AppWebView.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import UIKit
import WebKit

protocol WebViewDelegate: AnyObject {
    func dismissWebView()
}

enum WebViewConfigurationType {
    case persistCookies
    case ephemeral

    var configuration: WKWebViewConfiguration {
        let config = WKWebViewConfiguration()

        switch self {
        case .persistCookies:
            config.processPool = WebView.sharedSessionProcessPool

        case .ephemeral:
            config.websiteDataStore = .nonPersistent()
        }

        return config
    }
}

class WebView: WKWebView {
    private var userAgent: String {
        return Constants.userAgent
    }

    weak var delegate: WebViewDelegate?

    let appUrl: String?

    var successfullyLoadedOnce = false

    lazy var loadingView: LoadingView = LoadingView()
    lazy var placeholder: ErrorPlaceholderView = .init()

    init(with url: String?, configurationType: WebViewConfigurationType = .persistCookies) {
        self.appUrl = url

        super.init(frame: CGRect(), configuration: configurationType.configuration)

        setup()
        load(urlString: url)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func load(urlString: String?) {
        guard let urlString = urlString,
                let url = URL(string: urlString) else { return }
        load(URLRequest(url: url))
    }

    func setup() {
        self.customUserAgent = userAgent

        setupPlaceholderActions()
        setupDesign()
        setupView()
    }

    func setupPlaceholderActions() {
        placeholder.action = { [weak self] _ in
            self?.load(urlString: self?.appUrl ?? "")
        }

        placeholder.closeAction = { [weak self] in
            self?.delegate?.dismissWebView()
        }
    }

    func setupDesign() {
        self.isOpaque = false
        self.backgroundColor = UIColor.clear
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
    }

    func setupView() {
        navigationDelegate = self

        self.scrollView.bounces = false
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.backgroundColor = UIColor.clear
        self.scrollView.contentInsetAdjustmentBehavior = .never
        self.allowsBackForwardNavigationGestures = false
        self.isMultipleTouchEnabled = true

        addSubview(placeholder)
        addSubview(loadingView)

        placeholder.fillSuperview()

        loadingView.fillSuperview()

        placeholder.isHidden = true
        loadingView.isLoading = true
    }

    func showErrorState() {
        placeholder.isHidden = false
        loadingView.isLoading = false
        loadingView.isHidden = true
    }

    private func reportBreadcrumbs(_ message: String, parameters: [String: AnyHashable]?) {
        PACECloudSDK.shared.delegate?.reportBreadcrumbs(message, parameters: parameters)
        SDKLogger.v("\(message) - parameters: \(String(describing: parameters))")
    }

    private func reportError(_ message: String, parameters: [String: AnyHashable]?) {
        PACECloudSDK.shared.delegate?.reportError(message, parameters: parameters)
        SDKLogger.e("\(message) - parameters: \(String(describing: parameters))")
    }
}

extension WebView {
    static let sharedSessionProcessPool = WKProcessPool()
}

extension WebView: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation) {
        guard let webView = webView as? WebView else { return }
        webView.successfullyLoadedOnce = true
        webView.loadingView.isLoading = false
        webView.loadingView.isHidden = true
        webView.placeholder.isHidden = true
    }

    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let navigationUrl = navigationAction.request.url
        let navigationScheme = navigationUrl?.scheme?.lowercased()

        guard let url = navigationUrl, let scheme = navigationScheme else {
            reportError("[WebView] Canceled navigation action", parameters: ["url": navigationUrl, "scheme": navigationScheme])
            decisionHandler(.cancel)
            return
        }

        guard scheme != "https" && scheme != "http" else {
            decisionHandler(.allow)
            return
        }

        reportBreadcrumbs("[WebView] Received custom scheme to handle", parameters: ["url": url, "scheme": scheme])

        if scheme == Constants.fallbackRedirectScheme {
            reportBreadcrumbs("[WebView] Handling fallback redirect scheme", parameters: ["url": url, "scheme": scheme])
            PACECloudSDK.shared.application(open: url)
        } else if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            reportError("[WebView] Received unhandled url and scheme", parameters: ["url": url, "scheme": scheme])
        }

        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        guard let webView = webView as? WebView, let response = navigationResponse.response as? HTTPURLResponse else { decisionHandler(.allow); return }

        if !webView.successfullyLoadedOnce, response.statusCode == HttpStatusCode.notFound.rawValue {
            decisionHandler(.cancel)

            SDKLogger.e("Site couldn't be loaded. Showing placeholder instead.")

            webView.showErrorState()

            return
        }

        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation, withError error: Error) {
        guard let webView = webView as? WebView, !webView.successfullyLoadedOnce else { return }
        webView.showErrorState()
        reportError("[WebView] Failed provisional navigation with error \(error)", parameters: nil)
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) { // swiftlint:disable:this implicitly_unwrapped_optional
        guard let webView = webView as? WebView, !webView.successfullyLoadedOnce else { return }
        webView.showErrorState()
        reportError("[WebView] Failed navigation with error \(error)", parameters: nil)
    }
}
