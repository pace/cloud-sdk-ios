//
//  AppBase.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import WebKit

protocol App: WKWebView, WKScriptMessageHandler, SecureDataCommunication {
    var appUrl: String? { get }
    var placeholder: NoNetworkPlaceholderView { get set }
    var loadingView: LoadingView { get }
    var successfullyLoadedOnce: Bool { get set }
    var webViewDelegate: AppWebViewDelegate? { get }
    var interceptor: AppWebViewInterceptor? { get }
    var jsonRpcInterceptor: AppWebViewJsonRpcInterceptor { get }
    var appActionsDelegate: AppActionsDelegate? { get set }
    var appSecureCommunicationDelegate: AppSecureCommunicationDelegate? { get set }
    var paymentDelegate: AppPaymentDelegate? { get set }
    var reopenData: ReopenData? { get set }
}

extension App {
    func loadUrl(urlString: String?, cookies: [HTTPCookie] = []) {
        guard let urlString = urlString,
            let url = URL(string: urlString) else {
            AppKitLogger.e("[App] Can't load app url - url is nil")
            AppKit.shared.notifyDidFail(with: .failedRetrievingUrl)
            return
        }
        let urlRequest = URLRequest(url: url)
        load(urlRequest, with: cookies)
    }

    func loadUrlForVerifiedHost(urlString: String, host: String) {
        DispatchQueue.main.async {
            guard self.url?.host == host else {
                AppKitLogger.e("[App] Can't load URL, because host mismatch.")
                AppKit.shared.notifyDidFail(with: .failedRetrievingUrl)

                return
            }

            self.loadUrl(urlString: urlString)
        }
    }

    func load(_ request: URLRequest, with cookies: [HTTPCookie]) {
        var request = request
        let headers = HTTPCookie.requestHeaderFields(with: cookies)

        for (name, value) in headers {
            request.addValue(value, forHTTPHeaderField: name)
        }

        load(request)
    }

    func showErrorState() {
        placeholder.isHidden = false
        loadingView.isLoading = false
        loadingView.isHidden = true
    }

    func handleCloseAction(query: String?) {
        reopenData = ReopenData(from: query ?? "")

        guard let appActionsDelegate = appActionsDelegate else {
            // WebView directly added to client's view
            self.removeFromSuperview()
            return
        }

        // WebView opened in view controller
        appActionsDelegate.appRequestedCloseAction() // Close AppViewController if available
    }

    func handlePaymentAction(query: String) {
        guard let paymentConfirmationData = PaymentConfirmationData(from: query) else {
            AppKit.shared.notifyDidFail(with: .paymentError)
            return
        }

        self.paymentDelegate?.showPaymentConfirmation(with: paymentConfirmationData)
    }

    func provideReopenData() -> ReopenData? {
        return reopenData
    }

    func handleDisableAction(query: String, host: String) {
        let queryItems = URLDecomposer.decomposeQuery(query)

        guard let untilString = queryItems[URLParam.until.rawValue], let untilTime = Double(untilString) else { return }

        // Persist disable's until date
        AppKitLogger.i("[App] Set disable timer for \(host): \(untilTime)")
        UserDefaults.standard.set(untilTime, forKey: "disable_time_\(host)")

        // Close App after everything has been set
        guard let appActionsDelegate = appActionsDelegate else {
            // WebView directly added to client's view
            self.removeFromSuperview()
            return
        }

        // WebView opened in view controller
        appActionsDelegate.appRequestedDisableAction(for: host)
    }

    func handleOpenURLInNewTabAction(query: String, sourceUrl: URL) {
        let queryItems = URLDecomposer.decomposeQuery(query)

        guard let appActionsDelegate = appActionsDelegate else { return }

        guard let url: String = queryItems["url"], let cancelUrlString: String = queryItems["cancel_url"], let cancelUrl = URL(string: cancelUrlString) else {
            AppKit.shared.notifyDidFail(with: .badRequest)

            load(URLRequest(url: sourceUrl))

            return
        }

        guard let clientId = AppKit.shared.clientId, let customScheme = URL(string: "pace.\(clientId)://") else {
            AppKit.shared.notifyDidFail(with: .customURLSchemeNotSet)

            load(URLRequest(url: cancelUrl))

            return
        }

        if UIApplication.shared.canOpenURL(customScheme) {
            appActionsDelegate.appRequestedNewTab(for: url, cancelUrl: cancelUrl.absoluteString)
        } else {
            AppKit.shared.notifyDidFail(with: .customURLSchemeNotSet)

            load(URLRequest(url: cancelUrl))
        }
    }
}

// MARK: - Rpc
extension App {
    func handleInvalidTokenRequest() {
        guard AppKit.shared.authenticationMode == .native else { return }

        if let token = AppKit.shared.initialAccessToken, TokenValidator.isTokenValid(token) {
            jsonRpcInterceptor.respond(result: token)
        } else {
            sendInvalidTokenCallback()
        }

        AppKit.shared.initialAccessToken = nil
    }

    func handleImageDataRequest(with message: WKScriptMessage) {
        guard let imageString = message.body as? String,
              let decodedData = Data(base64Encoded: imageString),
              let image = UIImage(data: decodedData) else {
            AppKitLogger.e("[App] Could not decode base64 string")
            return
        }

        AppKit.shared.notifyImageData(with: image)
    }

    private func sendInvalidTokenCallback() {
        AppKit.shared.notifyInvalidToken { [weak self] token in
            if TokenValidator.isTokenValid(token) {
                AppKit.shared.currentAccessToken = token
                self?.jsonRpcInterceptor.respond(result: token)
            } else {
                self?.sendInvalidTokenCallback()
            }
        }
    }
}
