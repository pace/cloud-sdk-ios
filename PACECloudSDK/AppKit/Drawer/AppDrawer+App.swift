//
//  AppDrawer+App.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import UIKit

extension AppKit.AppDrawer: AppViewControllerDelegate {
    func preloadApp() {
        appViewController = nil

        if AppKit.shared.authenticationMode == .native,
           !TokenValidator.isTokenValid(AppKit.shared.currentAccessToken ?? "") {
            // Don't preload the appViewController
            return
        }

        initializeAppViewController()
    }

    func openApp() {
        if #available(iOS 13.0, *) {
            guard let application = UIApplication.value(forKeyPath: #keyPath(UIApplication.shared)) as? UIApplication else { return }
            let windowScene = application.connectedScenes.first

            if let windowScene = windowScene as? UIWindowScene {
                appWindow = AppWindow(windowScene: windowScene)
            }
        } else {
            appWindow = AppWindow(frame: UIScreen.main.bounds)
        }

        if appViewController == nil {
            initializeAppViewController()
        }

        guard let appViewController = appViewController else { return }

        appViewController.delegate = self
        appWindow?.show(with: appViewController)

        delegate?.didOpenApp()
    }

    override public func removeFromSuperview() {
        dismissAppViews()
        super.removeFromSuperview()
    }

    // MARK: - Called by AppViewController if closing was requested
    func appViewControllerRequestsClosing(reopenData: ReopenData?) {
        resetState(reopenData: reopenData)
    }

    func appViewControllerRequestsDisabling(host: String) {
        resetState(reopenData: nil)
        delegate?.didDisableApp(self, host: host)
    }

    private func initializeAppViewController() {
        let url = reopenUrl == nil ? appData.appStartUrl : reopenUrl
        appViewController = AppViewController(appUrl: url)
    }

    private func dismissAppViews() {
        appWindow?.dismissAppViewController { [weak self] in
            self?.appWindow = nil
        }
    }

    private func resetState(reopenData: ReopenData?) {
        titleLabel.text = reopenData?.reopenTitle ?? appData.appManifest?.name
        subtitleLabel.text = reopenData?.reopenSubtitle ?? appData.appManifest?.description
        reopenUrl = URLBuilder.buildAppReopenUrl(for: reopenData) ?? appData.appStartUrl

        currentState = .expanded
        isSlidingLocked = false

        dismissAppViews()

        preloadApp()
    }
}
