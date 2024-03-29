//
//  AppControl.swift
//  PACECloudSDKExample
//
//  Created by PACE Telematics GmbH.
//

import PACECloudSDK
import PassKit
import UIKit

protocol AppControlDelegate: AnyObject {
    func didReceiveDrawers(_ drawers: [AppKit.AppDrawer])
    func didFail()
}

class AppControl {
    static let shared = AppControl()
    weak var delegate: AppControlDelegate?

    // Use `AppData` as type to gain access to the app id
    var currentlyVisibleDrawers: [AppKit.AppData] = []

    private var didAuthorize = false

    private init() {
        AppKit.delegate = self
    }

    func requestLocalApps() {
        AppKit.requestLocalApps()
    }

    func appViewController(appUrl: String) -> UIViewController {
        AppKit.appViewController(appUrl: appUrl)
    }

    func isPoiInRange(with id: String) async -> Bool {
        await POIKit.isPoiInRange(id: id)
    }
}

extension AppControl: AppKitDelegate {
    func didReceiveAppData(_ appData: [AppKit.AppData]) {}

    func didFail(with error: AppKit.AppError) {
        switch error {
        case .locationNotAuthorized:
            ExampleLogger.i("[AppControl] Missing location access!")

        default:
            ExampleLogger.e("[AppControl] Did fail with error \(error)")
        }

        delegate?.didFail()
    }

    func didReceiveAppDrawers(_ appDrawers: [AppKit.AppDrawer], _ appDatas: [AppKit.AppData]) {
        currentlyVisibleDrawers = appDatas
        delegate?.didReceiveDrawers(appDrawers)
    }

    func didEscapeForecourt(_ appDatas: [AppKit.AppData]) {
        currentlyVisibleDrawers.removeAll(where: { appDatas.contains($0) })
    }
}
