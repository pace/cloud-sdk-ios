//
//  AppWebViewInterceptor.swift
//  PACECloudSlimSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

class AppWebViewInterceptor {
    private weak var app: App?

    private enum AppAction: String {
        case close = "close"
        case paymentConfirm = "payment-confirm"
        case disable
        case openURLInNewTab
        case undefined

        static let actionIdentifier = "action"
    }

    init(app: App) {
        self.app = app
    }

    func intercept(_ url: URL, sourceUrl: URL?) { // swiftlint:disable:this cyclomatic_complexity
        guard let host = url.host, host == AppAction.actionIdentifier,
              let appAction = AppAction(rawValue: url.lastPathComponent), appAction != .undefined else { return }

        guard let query = url.query, let sourceUrl: URL = sourceUrl, let sourceHost: String = sourceUrl.host else {
            switch appAction {
            case .close:
                app?.handleCloseAction(query: url.query)

            default:
                AppKit.shared.notifyDidFail(with: .badRequest)
            }

            return
        }

        switch appAction {
        case .close:
            app?.handleCloseAction(query: query)

        case .paymentConfirm:
            app?.handlePaymentAction(query: query)

        case .disable:
            app?.handleDisableAction(query: query, host: sourceHost)

        case .openURLInNewTab:
            app?.handleOpenURLInNewTabAction(query: query, sourceUrl: sourceUrl)

        case .undefined:
            return
        }
    }
}
