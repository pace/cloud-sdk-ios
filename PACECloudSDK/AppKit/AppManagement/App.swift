//
//  AppBase.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import CoreLocation
import Foundation
import PassKit
import WebKit

protocol App: WKWebView, WKScriptMessageHandlerWithReply, WKScriptMessageHandler, CommunicationProtocol {
    var appUrl: String? { get }
    var placeholder: ErrorPlaceholderView { get set }
    var loadingView: LoadingView { get }
    var successfullyLoadedOnce: Bool { get set }
    var webViewDelegate: AppWebViewDelegate? { get }
    var messageHandler: API.Communication.MessageHandler? { get }
    var appActionsDelegate: AppActionsDelegate? { get set }
    var oneTimeLocationProvider: OneTimeLocationProvider { get }
}

extension App {
    func loadUrl(urlString: String?, cookies: [HTTPCookie] = []) {
        guard let urlString = urlString,
            let url = URL(string: urlString) else {
            AppKitLogger.e("[App] Can't load app url - url is nil")
            AppKit.shared.notifyDidFail(with: .failedRetrievingUrl)
            return
        }

        // Add additional query parameter to request, if applicable
        guard let utmUrl = QueryParamHandler.buildUrl(for: url) else {
            AppKitLogger.e("[App] Can't load component url")
            AppKit.shared.notifyDidFail(with: .failedRetrievingUrl)
            return
        }

        load(URLRequest(url: utmUrl, withTracingId: true), with: cookies)
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

    func decode<T: Decodable>(from data: Data) -> T? {
        let request = try? JSONDecoder().decode(T.self, from: data)
        return request
    }

    func handleMessage(message: WKScriptMessage, with replyHandler: ((Any?, String?) -> Void)? = nil) {
        if message.name == ScriptMessageHandler.logger.rawValue,
           let body = message.body as? String {
            handleLog(with: body)
        } else {
            messageHandler?.handleAppMessage(message, with: replyHandler)
        }
    }

    func respond(result: String) {
        DispatchQueue.main.async { [weak self] in
            let jsString = result
                .replacingOccurrences(of: "'", with: "\u{2019}")
                .replacingOccurrences(of: "\\", with: "\u{005c}\u{005c}")

            let messageResponse = "window.postMessage('\(jsString)', window.origin)"
            self?.evaluateJavaScript(messageResponse, completionHandler: { _, error in
                if let error = error {
                    AppKitLogger.e("[AppWebViewMessageInterceptor] Error trying to inject JS, with error: \(error)")
                }
            })
        }
    }
}
