//
//  AppControl.swift
//  PACECloudSDKExample
//
//  Created by Patrick Niepel on 05.11.20.
//

import PACECloudSDK
import UIKit

protocol AppControlDelegate: AnyObject {
    func didReceiveDrawers(_ drawers: [AppKit.AppDrawer])
}

class AppControl {
    static let shared = AppControl()
    weak var delegate: AppControlDelegate?

    // Use `AppData` as type to gain access to the app id
    var currentlyVisibleDrawers: [AppKit.AppData] = []

    private var didAuthorize = false

    private init() {}

    func setup(with token: String) {
        AppKit.shared.delegate = self
        let config: AppKit.AppKitConfiguration = AppKit.AppKitConfiguration(clientId: "PACECloudSDKExample",
                                                              apiKey: "apikey",
                                                              accessToken: token,
                                                              environment: currentAppEnvironment())
        AppKit.shared.setup(config: config)
    }

    func requestLocalApps() {
        AppKit.shared.requestLocalApps()
    }

    func appViewController(appUrl: String) -> UIViewController {
        AppKit.shared.appViewController(appUrl: appUrl)
    }

    func handleRedirectURL(_ url: URL) {
        AppKit.shared.handleRedirectURL(url)
    }

    private func currentAppEnvironment() -> AppKit.AppEnvironment {
        #if PRODUCTION
            return .production
        #elseif STAGE
            return .stage
        #elseif SANDBOX
            return .sandbox
        #else
            return .development
        #endif
    }
}

extension AppControl: AppKitDelegate {
    func didFail(with error: AppKit.AppError) {
        switch error {
        case .locationNotAuthorized:
            NSLog("[AppControl] Missing location access!")

        default:
            break
        }
    }

    func didReceiveAppDrawers(_ appDrawers: [AppKit.AppDrawer], _ appDatas: [AppKit.AppData]) {
        currentlyVisibleDrawers = appDatas
        delegate?.didReceiveDrawers(appDrawers)
    }

    func didEscapeForecourt(_ appDatas: [AppKit.AppData]) {
        currentlyVisibleDrawers.removeAll(where: { appDatas.contains($0) })
    }

    func didReceiveImageData(_ image: UIImage) {
        let av = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        UIApplication.shared.windows.last?.rootViewController?.present(av, animated: true, completion: nil)
    }

    func tokenInvalid(completion: @escaping ((String) -> Void)) {
        IDControl.shared.refresh(completion)
    }
}
