//
//  AppWindow.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import UIKit

class AppWindow: UIWindow {
    var appViewController: UIViewController?
    var rootNav: UINavigationController?

    private let defaultWindowLevel = UIWindow.Level.normal + 1

    private var topMostWindowLevel: UIWindow.Level? {
        if #available(iOS 13.0, *) {
            return
                (UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene)?.windows
                .sorted(by: { $0.windowLevel > $1.windowLevel }).first?.windowLevel
        } else {
            return UIApplication.shared.windows.sorted(by: { $0.windowLevel > $1.windowLevel }).first?.windowLevel
        }
    }

    @available(iOS 13.0, *)
    override init(windowScene: UIWindowScene) {
        super.init(windowScene: windowScene)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func show(with viewController: UIViewController) {
        appViewController = viewController

        rootNav = UINavigationController(rootViewController: UIViewController())
        rootNav?.setNavigationBarHidden(true, animated: false)

        determineInterfaceStyle()

        rootViewController = rootNav
        windowLevel = topMostWindowLevel ?? defaultWindowLevel
        makeKeyAndVisible()

        appViewController?.modalPresentationStyle = .pageSheet
        appViewController?.modalPresentationCapturesStatusBarAppearance = true
        appViewController?.navigationController?.setNavigationBarHidden(true, animated: false)
        if #available(iOS 13.0, *) {
            appViewController?.isModalInPresentation = true
        }

        guard let vc = appViewController else { return }

        rootViewController?.present(vc, animated: true, completion: nil)
    }

    private func determineInterfaceStyle() {
        if #available(iOS 13.0, *) {
            if AppKit.shared.theme != .automatic {
                overrideUserInterfaceStyle = AppKit.shared.theme == .light ? .light : .dark
            }
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        guard #available(iOS 13.0, *), AppKit.shared.theme != .automatic else { return }

        overrideUserInterfaceStyle = AppKit.shared.theme == .light ? .light : .dark
    }
}
