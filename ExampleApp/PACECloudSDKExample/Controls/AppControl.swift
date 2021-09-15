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

    func handleRedirectURL(_ url: URL) {
        AppKit.handleRedirectURL(url)
    }

    func isPoiInRange(with id: String, completion: @escaping (Bool) -> Void) {
        POIKit.isPoiInRange(id: id, completion: completion)
    }
}

extension AppControl: AppKitDelegate {
    func didReceiveAppData(_ appData: [AppKit.AppData]) {}

    func didFail(with error: AppKit.AppError) {
        switch error {
        case .locationNotAuthorized:
            NSLog("[AppControl] Missing location access!")

        default:
            NSLog("[AppControl] Did fail with error \(error)")
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



    func paymentRequestMerchantIdentifier(completion: @escaping (String) -> Void) {
        completion("merchantIdentifier")
    }

    func didCreateApplePayPaymentRequest(_ request: PKPaymentRequest, completion: @escaping (API.Communication.ApplePayRequestResponse?) -> Void) {
        completion(.init(paymentMethod: .init(displayName: "DisplayName",
                                              network: "Network",
                                              type: .credit),
                         paymentData: .init(version: "123",
                                            data: "data",
                                            signature: "signature",
                                            header: .init(ephemeralPublicKey: "publicKey",
                                                          publicKeyHash: "hash",
                                                          transactionId: "transactionId")),
                         transactionIdentifier: "transactionIdentifier"))
    }
}
