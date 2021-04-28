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
    private var cancelUrl: String?

    private let webView: AppWebView
    private let completion: (() -> Void)?

    weak var delegate: AppViewControllerDelegate?

    required init(appUrl: String?, hasNavigationBar: Bool = false, completion: (() -> Void)? = nil) {
        self.completion = completion

        webView = AppWebView(with: appUrl)
        super.init(nibName: nil, bundle: nil)

        webView.appActionsDelegate = self

        NotificationCenter.default.addObserver(self, selector: #selector(handleRedirectURL(_:)), name: AppKit.Constants.NotificationIdentifier.caughtRedirectService, object: nil)

        navigationController?.setNavigationBarHidden(!hasNavigationBar, animated: false)
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
        guard let url = notification.userInfo?[AppKit.Constants.RedirectServiceParams.url] as? URL,
            let urlQuery = url.query,
            let redirectUrlString = RedirectServiceData(from: urlQuery).to
        else {
            return
        }

        handleRedirectService(url: redirectUrlString)
    }
}

extension AppViewController {
    func handleRedirectService(url: String) {
        sfSafariViewController?.dismiss(animated: true) {
            self.sfSafariViewController = nil
            self.webView.loadUrl(urlString: url)
        }
    }
}

// MARK: - AppActionsDelegate
extension AppViewController: AppActionsDelegate {
    func appRequestedNewTab(for urlString: String, cancelUrl: String) {
        guard let url = URL(string: urlString) else { return }

        self.cancelUrl = cancelUrl

        sfSafariViewController = SFSafariViewController(url: url)
        sfSafariViewController?.delegate = self

        if #available(iOS 13.0, *) {
            sfSafariViewController?.modalPresentationStyle = .pageSheet
        }

        sfSafariViewController?.presentationController?.delegate = self

        present(sfSafariViewController!, animated: true) // swiftlint:disable:this force_unwrapping
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
