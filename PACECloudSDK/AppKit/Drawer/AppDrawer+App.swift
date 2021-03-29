//
//  AppDrawer+App.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import UIKit

public extension AppKit.AppDrawer {
    @objc
    open func openApp() {
        guard let appViewController = appViewController else { return }
        appWindow?.show(with: appViewController)
    }
}

extension AppKit.AppDrawer: AppViewControllerDelegate {
    func preloadApp() {
        appViewController = nil

        // Don't preload the appViewController
        if PACECloudSDK.shared.authenticationMode == .native {
            guard let token = PACECloudSDK.shared.currentAccessToken, !token.isEmpty, AppKit.TokenValidator.isTokenValid(token) else { return }
        }

        initializeAppViewController()
    }

    func prepareForOpenApp() {
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

        appViewController?.delegate = self

        openApp()

        delegate?.didOpenApp()
    }

    override public func removeFromSuperview() {
        dismissAppViews()
        super.removeFromSuperview()
    }

    // MARK: - Called by AppViewController if closing was requested
    func appViewControllerRequestsClosing() {
        resetState()
    }

    func appViewControllerRequestsDisabling(host: String) {
        resetState()
        delegate?.didDisableApp(self, host: host)
    }

    func forceCloseApp() {
        isSlidingLocked = false
        dismissAppViews()
        preloadApp()
    }

    private func initializeAppViewController() {
        let url = appData.appStartUrl
        appViewController = AppViewController(appUrl: url)
    }

    private func dismissAppViews() {
        appViewController?.dismiss(animated: true) { [weak self] in
            self?.appWindow = nil
        }
    }

    private func resetState() {
        titleLabel.text = appData.appManifest?.name
        subtitleLabel.text = appData.appManifest?.description

        currentState = .expanded
        isSlidingLocked = false

        dismissAppViews()

        preloadApp()
    }
}
