//
//  AppWebView.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import UIKit
import WebKit

class WebView: WKWebView {
    private var userAgent: String {
        return AppKit.Constants.userAgent
    }

    let appUrl: String?
    var successfullyLoadedOnce = false

    lazy var loadingView: LoadingView = LoadingView()
    lazy var placeholder: ErrorPlaceholderView = .init()

    required init(with url: String?) {
        self.appUrl = url

        let config = WKWebViewConfiguration()
        config.processPool = AppWebView.sharedSessionProcessPool

        super.init(frame: CGRect(), configuration: config)

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

        setupDesign()
        setupView()
    }

    private func setupDesign() {
        self.isOpaque = false
        self.backgroundColor = UIColor.clear
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
    }

    func setupView() {

        navigationDelegate = self

        placeholder.action = { [weak self] _ in
            self?.load(urlString: self?.appUrl ?? "")
        }

        placeholder.closeAction = { [weak self] in
            
        }

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
        if let url = navigationAction.request.url, let scheme = url.scheme?.lowercased() {
            if scheme != "https" && scheme != "http" {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            }
        }

        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        guard let webView = webView as? WebView, let response = navigationResponse.response as? HTTPURLResponse else { decisionHandler(.allow); return }

        if !webView.successfullyLoadedOnce, response.statusCode == HttpStatusCode.notFound.rawValue {
            decisionHandler(.cancel)

            AppKitLogger.e("Site couldn't be loaded. Showing placeholder instead.")

            webView.placeholder.isHidden = false

            return
        }

        decisionHandler(.allow)
    }
}
