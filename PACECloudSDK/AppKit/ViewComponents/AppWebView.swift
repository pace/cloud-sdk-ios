//
//  AppWebView.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import UIKit
import WebKit

protocol AppActionsDelegate: AnyObject {
    func appRequestedCloseAction()
    func appRequestedDisableAction(for host: String)
    func appRequestedNewTab(for urlString: String, cancelUrl: String, integrated: Bool)
}

class AppWebView: WebView, App {
    weak var appActionsDelegate: AppActionsDelegate?

    private(set) var webViewDelegate: AppWebViewDelegate? // swiftlint:disable:this weak_delegate
    private(set) var messageHandler: API.Communication.MessageHandler?
    private(set) lazy var oneTimeLocationProvider: OneTimeLocationProvider = .init()

    override func setup() {
        attachMessageHandlers()

        webViewDelegate = .init(app: self)
        messageHandler = .init(delegate: self)
        super.setup()
    }

    private func attachMessageHandlers() {
        if #available(iOS 14.0, *) {
            self.configuration.userContentController.addScriptMessageHandler(self, contentWorld: .page, name: ScriptMessageHandler.nativeAPIWithReply.rawValue)
        } else {
            self.configuration.userContentController.add(self, name: ScriptMessageHandler.nativeAPI.rawValue)
        }

        self.configuration.userContentController.add(self, name: ScriptMessageHandler.logger.rawValue)
    }

    override func setupView() {
        super.setupView()
        uiDelegate = webViewDelegate
        navigationDelegate = webViewDelegate
        scrollView.delegate = webViewDelegate

        placeholder.action = { [weak self] _ in
            self?.loadUrl(urlString: self?.appUrl ?? "")
        }

        placeholder.closeAction = { [weak self] in
            self?.appActionsDelegate?.appRequestedCloseAction()
        }
    }

    override func load(urlString: String?) {
        DispatchQueue.main.async { [weak self] in
            let dispatchGroup = DispatchGroup()

            let cookies = AppKit.CookieStorage.sharedSessionCookies

            for cookie in cookies {
                dispatchGroup.enter()
                self?.configuration.websiteDataStore.httpCookieStore.setCookie(cookie) {
                    dispatchGroup.leave()
                }
            }

            dispatchGroup.notify(queue: .main) { [weak self] in
                self?.loadUrl(urlString: self?.appUrl, cookies: cookies)
            }
        }
    }

    func cleanUp() {
        ScriptMessageHandler.allCases.forEach {
            self.configuration.userContentController.removeScriptMessageHandler(forName: $0.rawValue)
        }
    }
}

// MARK: - WKScriptMessageHandler
extension AppWebView {
    @objc
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        handleMessage(message: message)
    }
}

// MARK: - WKScriptMessageHandlerWithRepy
@available(iOS 14, *)
extension AppWebView {
    @objc
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage, replyHandler: @escaping (Any?, String?) -> Void) {
        handleMessage(message: message, with: replyHandler)
    }
}
