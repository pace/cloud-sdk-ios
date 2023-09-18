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
        return (UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene)?.windows
            .sorted(by: { $0.windowLevel > $1.windowLevel }).first?.windowLevel
    }

    override init(windowScene: UIWindowScene) {
        super.init(windowScene: windowScene)
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
        appViewController?.isModalInPresentation = true

        guard let vc = appViewController else { return }

        rootViewController?.present(vc, animated: true, completion: nil)
    }

    private func determineInterfaceStyle() {
        guard AppKit.shared.theme != .automatic else { return }
        overrideUserInterfaceStyle = AppKit.shared.theme == .light ? .light : .dark
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        guard AppKit.shared.theme != .automatic else { return }

        overrideUserInterfaceStyle = AppKit.shared.theme == .light ? .light : .dark
    }
}
