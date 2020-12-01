//
//  AppWebViewInterceptor.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

class AppWebViewInterceptor {
    private weak var app: App?

    private enum AppAction: String {
        case close = "close"
        case paymentConfirm = "payment-confirm"
        case getBiometricStatus
        case setTOTPSecret
        case getTOTP
        case setSecureData
        case getSecureData
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

        case .getBiometricStatus:
            app?.handleBiometryAvailbilityRequest(query: query, host: sourceHost)

        case .setTOTPSecret:
            app?.setTOTPSecret(query: query, host: sourceHost)

        case .getTOTP:
            app?.getTOTP(query: query, host: sourceHost)

        case .setSecureData:
            app?.setSecureData(query: query, host: sourceHost)

        case .getSecureData:
            app?.getSecureData(query: query, host: sourceHost)

        case .disable:
            app?.handleDisableAction(query: query, host: sourceHost)

        case .openURLInNewTab:
            app?.handleOpenURLInNewTabAction(query: query, sourceUrl: sourceUrl)

        case .undefined:
            return
        }
    }
}
