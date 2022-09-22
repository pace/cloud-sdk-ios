//
//  AppDriveModeViewController.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import NotificationCenter
import SafariServices
import WebKit

protocol AppViewControllerDelegate: AnyObject {
    func appViewControllerRequestsClosing()
    func appViewControllerRequestsDisabling(host: String)
}

public class AppViewController: UIViewController {
    private var sfSafariViewController: SFSafariViewController?
    private var integratedWebView: WebViewController?
    private var cancelUrl: String?

    private let webView: AppWebView
    private let completion: (() -> Void)?

    weak var delegate: AppViewControllerDelegate?

    init(appUrl: String?,
         hasNavigationBar: Bool = false,
         isModalInPresentation: Bool = true,
         completion: (() -> Void)? = nil) {
        self.completion = completion

        webView = AppWebView(with: appUrl)
        super.init(nibName: nil, bundle: nil)

        webView.appActionsDelegate = self

        NotificationCenter.default.addObserver(self, selector: #selector(handleRedirectURL(_:)), name: AppKit.Constants.NotificationIdentifier.caughtRedirectService, object: nil)

        navigationController?.setNavigationBarHidden(!hasNavigationBar, animated: false)

        if #available(iOS 13.0, *) {
            self.isModalInPresentation = isModalInPresentation
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        webView.cleanUp()

        NotificationCenter.default.removeObserver(self)
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
            guard !cookies.isEmpty else { return }
            AppKit.CookieStorage.sharedSessionCookies = cookies
            AppKit.CookieStorage.saveCookies(cookies)
        }

        if isBeingDismissed {
            completion?()
        }
    }

    private func setupView() {
        view.addSubview(webView)
        view.backgroundColor = AppStyle.backgroundColor1
        navigationController?.navigationBar.tintColor = AppStyle.whiteColor
        webView.fillSuperview()
    }

    public func close() {
        guard let nav = self.navigationController else {
            // Is being presented
            self.dismiss(animated: true)
            return
        }

        // If rootViewController
        if nav.viewControllers.first === self {
            navigationController?.dismiss(animated: true)
        } else {
            nav.popViewController(animated: true)
        }

        completion?()
    }

    @objc
    private func handleRedirectURL(_ notification: NSNotification) {
        let url = notification.userInfo?[AppKit.Constants.RedirectServiceParams.url] as? URL

        guard let url = url, let urlQuery = url.query else {
            reportError("[AppViewController] Couldn't get url or query to handle redirect", parameters: ["url": url, "query": url?.query])
            return
        }

        guard let redirectUrlString = RedirectServiceData(from: urlQuery).to else {
            reportError("[AppViewController] Couldn't extract redirect url", parameters: ["url": url, "query": urlQuery])
            return
        }

        handleRedirectService(url: redirectUrlString)
    }

    private func reportError(_ message: String, parameters: [String: AnyHashable]?) {
        PACECloudSDK.shared.delegate?.reportError(message, parameters: parameters)
        SDKLogger.e("\(message) - parameters: \(String(describing: parameters))")
    }
}

private extension AppViewController {
    func handleRedirectService(url: String) {
        if let webVC = integratedWebView {
            webVC.dismiss(animated: true) { [weak self] in
                self?.integratedWebView = nil
                self?.webView.loadUrl(urlString: url)
            }
        } else {
            sfSafariViewController?.dismiss(animated: true) { [weak self] in
                self?.sfSafariViewController = nil
                self?.webView.loadUrl(urlString: url)
            }
        }
    }

    func presentIntegratedWebView(with urlString: String) {
        let presentationBlock: (String) -> Void = { [weak self] urlString in
            guard let self = self else { return }
            let integratedWebView = WebViewController(appUrl: urlString)
            integratedWebView.delegate = self
            integratedWebView.modalPresentationStyle = .pageSheet
            integratedWebView.presentationController?.delegate = self
            self.integratedWebView = integratedWebView
            self.present(integratedWebView, animated: true)
        }

        guard let webVC = integratedWebView else {
            presentationBlock(urlString)
            return
        }

        webVC.dismiss(animated: false) { [weak self] in
            self?.integratedWebView = nil
            presentationBlock(urlString)
        }
    }

    func presentSFSafariViewController(with url: URL) {
        let presentationBlock: (URL) -> Void = { [weak self] url in
            guard let self = self else { return }
            let sfSafariViewController = SFSafariViewController(url: url)
            sfSafariViewController.delegate = self

            if #available(iOS 13.0, *) {
                sfSafariViewController.modalPresentationStyle = .pageSheet
            }

            sfSafariViewController.presentationController?.delegate = self
            self.sfSafariViewController = sfSafariViewController
            self.present(sfSafariViewController, animated: true)
        }

        guard let sfSafariViewController = sfSafariViewController else {
            presentationBlock(url)
            return
        }

        sfSafariViewController.dismiss(animated: false) { [weak self] in
            self?.sfSafariViewController = nil
            presentationBlock(url)
        }
    }
}

// MARK: - AppActionsDelegate
extension AppViewController: AppActionsDelegate {
    func appRequestedNewTab(for urlString: String, cancelUrl: String, integrated: Bool) {
        guard let url = URL(string: urlString) else {
            AppKitLogger.e("[AppViewController] appRequestedNewTab failed due to invalid url - \(urlString)")
            return
        }

        self.cancelUrl = cancelUrl

        // Apple pay support in WKWebView came with iOS 13
        // Reference: https://webkit.org/blog/9674/new-webkit-features-in-safari-13/
        if #available(iOS 13.0, *), integrated {
            presentIntegratedWebView(with: urlString)
        } else {
            presentSFSafariViewController(with: url)
        }
    }

    func appRequestedCloseAction() {
        guard let delegate = delegate else {
            // ViewController opened without drawer
            close()
            return
        }

        // ViewController opened with drawer
        delegate.appViewControllerRequestsClosing()
    }

    func appRequestedDisableAction(for host: String) {
        if let delegate = delegate {
            delegate.appViewControllerRequestsDisabling(host: host)
        } else {
            // ViewController opened without drawer
            close()
        }
    }
}

// MARK: - SFSafariViewControllerDelegate
extension AppViewController: SFSafariViewControllerDelegate {
    public func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        // SFSafariViewController was dismissed by selecting 'Finish'
        webView.loadUrl(urlString: cancelUrl)
        cancelUrl = nil
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate
extension AppViewController: UIAdaptivePresentationControllerDelegate {
    public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        // `SFSafariViewController` was dismissed by pulling down
        webView.loadUrl(urlString: cancelUrl)
        cancelUrl = nil
    }
}

extension AppViewController: WebViewControllerDelegate {
    func dismiss(webViewController: WebViewController) {
        webViewController.dismiss(animated: true) { [weak self] in
            self?.integratedWebView = nil
            self?.close()
        }
    }
}
