//
//  AppDriveModeViewController.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import NotificationCenter
import SafariServices
import WebKit

protocol AppViewControllerDelegate: class {
    func appViewControllerRequestsClosing(reopenData: ReopenData?)
    func appViewControllerRequestsDisabling(host: String)
}

class AppViewController: UIViewController, AppPaymentDelegate {
    var paymentConfirmationController: PaymentConfirmationViewController?
    private var paymentConfirmationData: PaymentConfirmationData?

    var webView: AppWebView

    private var sfSafariViewController: SFSafariViewController?
    private var cancelUrl: String?

    weak var delegate: AppViewControllerDelegate?

    required init(appUrl: String?, hasNavigationBar: Bool = false) {
        webView = AppWebView(with: appUrl)
        super.init(nibName: nil, bundle: nil)

        webView.paymentDelegate = self
        webView.appActionsDelegate = self
        webView.appSecureCommunicationDelegate = self

        NotificationCenter.default.addObserver(self, selector: #selector(handleRedirectURL(_:)), name: AppKitConstants.NotificationIdentifier.caughtRedirectService, object: nil)

        navigationController?.setNavigationBarHidden(!hasNavigationBar, animated: false)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        webView.removeFromSuperview()

        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
            guard !cookies.isEmpty else { return }
            AppKit.CookieStorage.sharedSessionCookies = cookies
            AppKit.CookieStorage.saveCookies(cookies)
        }
    }

    private func setupView() {
        view.addSubview(webView)
        view.backgroundColor = AppStyle.backgroundColor1
        navigationController?.navigationBar.tintColor = AppStyle.whiteColor
        webView.fillSuperview()
    }

    private func close() {
        // If attached to a navigationController
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        } else {
            // If being presented
            self.dismiss(animated: true)
        }
    }

    @objc
    private func handleRedirectURL(_ notification: NSNotification) {
        guard let url = notification.userInfo?[AppKitConstants.RedirectServiceParams.url] as? URL,
            let urlQuery = url.query,
            let redirectUrlString = RedirectServiceData(from: urlQuery).to
        else {
            return
        }

        handleRedirectService(url: redirectUrlString)
    }

    func showPaymentConfirmation(with paymentConfirmationData: PaymentConfirmationData) {
        self.paymentConfirmationData = paymentConfirmationData

        DispatchQueue.main.async {
            self.paymentConfirmationController = PaymentConfirmationViewController(delegate: self, datasource: self)
            self.present(self.paymentConfirmationController!, animated: true) // swiftlint:disable:this force_unwrapping
        }
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
        delegate.appViewControllerRequestsClosing(reopenData: webView.provideReopenData())
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
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        // SFSafariViewController was dismissed by selecting 'Finish'
        webView.loadUrl(urlString: cancelUrl)
        cancelUrl = nil
    }
}

// MARK: - PaymentConfirmationControllerDelegate
extension AppViewController: PaymentConfirmationControllerDelegate {
    func paymentConfirmationController(didFinishWithResult result: PaymentConfirmationViewController.PaymentConfirmationResult) {
        paymentConfirmationController?.dismiss(animated: true)

        // Redirect user
        guard var data = paymentConfirmationData else {
            AppKit.shared.notifyDidFail(with: .paymentError)
            AppKitLogger.e("[AppViewController] Couldn't retrieve paymentConfirmationData")
            return
        }
        data.statusCode = PaymentConfirmationData.StatusCode(paymentResult: result).rawValue

        guard let redirectUri = URLBuilder.buildAppPaymentRedirectUrl(for: data) else { fatalError() }

        webView.loadUrl(urlString: redirectUri)
    }
}

// MARK: - PaymentConfirmationControllerDataSource
extension AppViewController: PaymentConfirmationControllerDataSource {
    func paymentConfirmationController(dataFor paymentController: PaymentConfirmationViewController) -> PaymentConfirmationData {
        guard let data = paymentConfirmationData else { fatalError() }
        return data
    }
}

// MARK: - 2FA
extension AppViewController: AppSecureCommunicationDelegate {
    func sendBiometryStatus(data: BiometryAvailabilityData) {
        guard let url = URLBuilder.buildBiometricStatusResponse(for: data) else { fatalError() }

        webView.loadUrlForVerifiedHost(urlString: url, host: data.host)
    }

    func sendSetTOTPResponse(data: SetTOTPResponse) {
        guard let url = URLBuilder.buildSetTOTPResponse(for: data) else { fatalError() }

        webView.loadUrlForVerifiedHost(urlString: url, host: data.host)
    }

    func sendGetTOTPResponse(data: GetTOTPData) {
        guard let url = URLBuilder.buildGetTOTPResponse(for: data) else { fatalError() }

        webView.loadUrlForVerifiedHost(urlString: url, host: data.host)
    }

    func sendSetSecureDataResponse(data: SetSecureDataResponse) {
        guard let url = URLBuilder.buildSetSecureDataResponse(for: data) else { fatalError() }

        webView.loadUrlForVerifiedHost(urlString: url, host: data.host)
    }

    func sendGetSecureDataResponse(data: GetSecureData) {
        guard let url = URLBuilder.buildGetSecureDataResponse(for: data) else { fatalError() }

        webView.loadUrlForVerifiedHost(urlString: url, host: data.host)
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate
extension AppViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        // `SFSafariViewController` was dismissed by pulling down
        webView.loadUrl(urlString: cancelUrl)
        cancelUrl = nil
    }
}
