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
    func appRequestedNewTab(for urlString: String, cancelUrl: String)
}

class AppWebView: WKWebView, App {
    private var userAgent: String {
        return AppKitConstants.userAgent
    }

    weak var appActionsDelegate: AppActionsDelegate?

    private(set) var webViewDelegate: AppWebViewDelegate? // swiftlint:disable:this weak_delegate
    private(set) var jsonRpcInterceptor: AppWebViewJsonRpcInterceptor?
    private(set) lazy var oneTimeLocationProvider: OneTimeLocationProvider = .init()

    let appUrl: String?
    var successfullyLoadedOnce = false

    lazy var loadingView: LoadingView = LoadingView()
    lazy var placeholder: NoNetworkPlaceholderView = {
        NoNetworkPlaceholderView(titleText: "app.loading.error".localized,
                                        placeholderText: "",
                                        buttonText: "user.alert.retry".localized,
                                        image: AppStyle.iconNotificationError)
    }()

    required init(with url: String?) {
        self.appUrl = url

        let config = WKWebViewConfiguration()
        config.processPool = AppWebView.sharedSessionProcessPool

        super.init(frame: CGRect(), configuration: config)

        setup()

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

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        self.customUserAgent = userAgent

        // Attach json rpc handlers
        AppWebViewJsonRpcInterceptor.JsonRpcHandler.allCases.forEach {
            self.configuration.userContentController.add(self, name: $0.rawValue)
        }

        webViewDelegate = AppWebViewDelegate(app: self)
        jsonRpcInterceptor = AppWebViewJsonRpcInterceptor(app: self)

        setupDesign()
        setupView()
    }

    private func setupDesign() {
        self.isOpaque = false
        self.backgroundColor = UIColor.clear
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
    }

    private func setupView() {
        self.scrollView.bounces = false
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.backgroundColor = UIColor.clear
        self.scrollView.contentInsetAdjustmentBehavior = .never
        self.allowsBackForwardNavigationGestures = false
        self.isMultipleTouchEnabled = true

        uiDelegate = webViewDelegate
        navigationDelegate = webViewDelegate
        scrollView.delegate = webViewDelegate

        placeholder.action = { [weak self] _ in
            self?.loadUrl(urlString: self?.appUrl ?? "")
        }

        placeholder.closeAction = { [weak self] in
            self?.appActionsDelegate?.appRequestedCloseAction()
        }

        addSubview(placeholder)
        addSubview(loadingView)

        placeholder.fillSuperview()

        loadingView.fillSuperview()

        placeholder.isHidden = true
        loadingView.isLoading = true
    }

    func cleanUp() {
        AppWebViewJsonRpcInterceptor.JsonRpcHandler.allCases.forEach {
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
        jsonRpcInterceptor?.parseJsonRpcRequest(message: message)
    }
}
