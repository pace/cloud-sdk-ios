//
//  PaceIDSignInWindow.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import UIKit

class PaceIDSignInWindow: UIWindow {
    var baseViewController: UIViewController?

    @available(iOS 13.0, *)
    override required init(windowScene: UIWindowScene) {
        super.init(windowScene: windowScene)
        setup()
    }

    override required init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup() {
        let baseViewController = WindowBaseViewController()
        self.baseViewController = baseViewController

        let rootNav = UINavigationController(rootViewController: baseViewController)
        rootNav.setNavigationBarHidden(true, animated: false)

        self.rootViewController = .init()
        self.windowLevel = UIWindow.topMostWindowLevel ?? UIWindow.Level.alert - 1
        self.makeKeyAndVisible()

        self.rootViewController = rootNav
    }
}

private extension PaceIDSignInWindow {
    private class WindowBaseViewController: UIViewController {
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)

            view.backgroundColor = .clear

            if #available(iOS 13.0, *) {
                setNeedsStatusBarAppearanceUpdate()
            }
        }
    }
}

extension PaceIDSignInWindow {
    static func create() -> PaceIDSignInWindow? {
        var window: PaceIDSignInWindow?

        if #available(iOS 13.0, *) {
            guard let application = UIApplication.value(forKeyPath: #keyPath(UIApplication.shared)) as? UIApplication else { return nil }
            let windowScene = application.connectedScenes.first

            if let windowScene = windowScene as? UIWindowScene {
                window = PaceIDSignInWindow(windowScene: windowScene)
            }
        } else {
            window = PaceIDSignInWindow(frame: UIScreen.main.bounds)
        }

        return window
    }
}
