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
    private var userAgent: String {
        return AppKit.Constants.userAgent
    }

    weak var appActionsDelegate: AppActionsDelegate?

    private(set) var webViewDelegate: AppWebViewDelegate? // swiftlint:disable:this weak_delegate
    private(set) var messageHandler: API.Communication.MessageHandler?
    private(set) lazy var oneTimeLocationProvider: OneTimeLocationProvider = .init()

    required init(with url: String?) {
        super.init(with: url)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setup() {
        addCustomScripts()

        // Attach message handlers
        ScriptMessageHandler.allCases.forEach {
            self.configuration.userContentController.add(self, name: $0.rawValue)
        }

        webViewDelegate = .init(app: self)
        messageHandler = .init(delegate: self)
        super.setup()
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

    private func addCustomScripts() {
        // Needed to intercept the web view's console log messages
        let loggingSource = """
            function log(level, args) {
              window.webkit.messageHandlers.pace_logger.postMessage(
                `${level} ${Object.values(args)
                  .map(v => typeof(v) === "undefined" ? "undefined" : typeof(v) === "object" ? JSON.stringify(v) : v.toString())
                  .map(v => v.substring(0, 3000)) // Limit msg to 3000 chars
                  .join(", ")}`
              );
            }

            var originalLog = console.log;
            var originalWarn = console.warn;
            var originalError = console.error;
            var originalDebug = console.debug;

            console.log = function() { log("[I]", arguments); originalLog.apply(null, arguments); };
            console.warn = function() { log("[W]", arguments); originalWarn.apply(null, arguments); };
            console.error = function() { log("[E]", arguments); originalError.apply(null, arguments); };
            console.debug = function() { log("[D]", arguments); originalDebug.apply(null, arguments); };

            window.addEventListener("error", function(e) {
               log("[Uncaught]", [`${e.message} at ${e.filename}:${e.lineno}:${e.colno}`]);
            });
        """

        // Enable a set of PWA features
        let featuresSource = """
        window.features = {
            messageIds: true
        }
        """

        [loggingSource, featuresSource].forEach {
            let script = WKUserScript(source: $0, injectionTime: .atDocumentStart, forMainFrameOnly: false)
            configuration.userContentController.addUserScript(script)
        }
    }

    func cleanUp() {
        ScriptMessageHandler.allCases.forEach {
            self.configuration.userContentController.removeScriptMessageHandler(forName: $0.rawValue)
        }
    }
}

extension AppWebView {
    static let sharedSessionProcessPool = WKProcessPool()
}

// MARK: - WKScriptMessageHandler
extension AppWebView {
    @objc
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        handleMessage(message: message)
    }
}
