//
//  AppWebViewDelegate.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import SafariServices
import WebKit

class AppWebViewDelegate: NSObject, WKNavigationDelegate, UIScrollViewDelegate, WKUIDelegate {

    private weak var app: App?

    init(app: App) {
        self.app = app
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }

        // We only want http & https to be handled by the webview itself
        guard url.isFileURL || url.scheme == "http" || url.scheme == "https" else {
            UIApplication.shared.open(url)

            decisionHandler(.cancel)

            AppKitLogger.v("[AppViewController] Canceled navigation and passed handling to system.")

            return
        }

        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView,
                 createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction,
                 windowFeatures: WKWindowFeatures) -> WKWebView? {
        guard let url = navigationAction.request.url else { return nil }

        if navigationAction.navigationType == .linkActivated && UIApplication.shared.canOpenURL(url) {
            // Open links in system browser
            UIApplication.shared.open(url)

            return nil
        }

        return webView
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation, withError error: Error) {
        guard let app = app, !app.successfullyLoadedOnce else { return }

        app.showErrorState()

        AppKitLogger.e("[WebView] Failed provisional navigation with error \(error.localizedDescription)")
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation) {
        guard let app = app else { return }
        app.successfullyLoadedOnce = true
        app.loadingView.isLoading = false
        app.loadingView.isHidden = true
        app.placeholder.isHidden = true
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        guard let app = app, let response = navigationResponse.response as? HTTPURLResponse else { decisionHandler(.allow); return }

        webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
            guard !cookies.isEmpty else { return }

            AppKit.CookieStorage.sharedSessionCookies = cookies
            AppKit.CookieStorage.saveCookies(cookies)
        }

        if let headerFields = response.allHeaderFields as? [String: String],
            let url = response.url {

            let cookies = HTTPCookie.cookies(withResponseHeaderFields: headerFields, for: url)
            cookies.forEach { cookie in
                webView.configuration.websiteDataStore.httpCookieStore.setCookie(cookie)
            }
        }

        if !app.successfullyLoadedOnce, response.statusCode == HttpStatusCode.notFound.rawValue {
            decisionHandler(.cancel)

            AppKitLogger.e("App couldn't be loaded. Showing placeholder instead.")

            app.placeholder.isHidden = false

            return
        }

        decisionHandler(.allow)
    }

    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.pinchGestureRecognizer?.isEnabled = false
    }
}
