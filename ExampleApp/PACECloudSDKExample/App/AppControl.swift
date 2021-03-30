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

    private init() {
        AppKit.shared.delegate = self
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

    func isPoiInRange(with id: String) {
        AppKit.shared.isPoiInRange(id: id) { result in
            NSLog("\(id) in range: \(result)")
        }
    }
}

extension AppControl: AppKitDelegate {
    func didReceiveAppData(_ appData: [AppKit.AppData]) {}

    func didReceiveApplePayDataRequest(_ request: AppKit.ApplePayRequest, completion: @escaping (([String: Any]?) -> Void)) {
        completion(nil)
    }

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
