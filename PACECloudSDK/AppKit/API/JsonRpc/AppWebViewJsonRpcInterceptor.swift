//
//  AppWebViewJsonRpcInterceptor.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation
import WebKit

class AppWebViewJsonRpcInterceptor {
    enum JsonRpcHandler: String, CaseIterable {
        case close = "pace_close"
        case getBiometricStatus = "pace_getBiometricStatus"
        case setTOTPSecret = "pace_setTOTPSecret"
        case getTOTP = "pace_getTOTP"
        case setSecureData = "pace_setSecureData"
        case getSecureData = "pace_getSecureData"
        case disable = "pace_disable"
        case openURLInNewTab = "pace_openURLInNewTab"
        case invalidToken = "pace_invalidToken"
        case imageData = "pace_imageData"
        case applePayAvailabilityCheck = "pace_applePayAvailabilityCheck"
        case applePayRequest = "pace_applePayRequest"
        case verifyLocation = "pace_verifyLocation"
        case logger = "pace_logger"
        case back = "pace_back"
    }

    private weak var app: App?

    init(app: App) {
        self.app = app
    }

    // swiftlint:disable cyclomatic_complexity
    func parseJsonRpcRequest(message: WKScriptMessage) {
        switch message.name {
        case JsonRpcHandler.close.rawValue:
            app?.handleCloseAction()

        case JsonRpcHandler.getBiometricStatus.rawValue:
            app?.handleBiometryAvailbilityRequest()

        case JsonRpcHandler.setTOTPSecret.rawValue:
            app?.setTOTPSecret(with: message)

        case JsonRpcHandler.getTOTP.rawValue:
            app?.getTOTP(with: message)

        case JsonRpcHandler.setSecureData.rawValue:
            app?.setSecureData(with: message)

        case JsonRpcHandler.getSecureData.rawValue:
            app?.getSecureData(with: message)

        case JsonRpcHandler.disable.rawValue:
            app?.handleDisableAction(with: message)

        case JsonRpcHandler.openURLInNewTab.rawValue:
            app?.handleOpenURLInNewTabAction(with: message)

        case JsonRpcHandler.invalidToken.rawValue:
            app?.handleInvalidTokenRequest()

        case JsonRpcHandler.imageData.rawValue:
            app?.handleImageDataRequest(with: message)

        case JsonRpcHandler.applePayAvailabilityCheck.rawValue:
            app?.handleApplePayAvailibilityCheck(with: message)

        case JsonRpcHandler.applePayRequest.rawValue:
            app?.handleApplePayPaymentRequest(with: message)

        case JsonRpcHandler.verifyLocation.rawValue:
            app?.handleVerifyLocationRequest(with: message)

        case JsonRpcHandler.logger.rawValue:
            app?.handleLog(with: message)

        case JsonRpcHandler.back.rawValue:
            app?.handleBack()

        default:
            send(error: .badRequest)
        }
    }

    func respond(result: String) {
        DispatchQueue.main.async {
            let jsonRpcResponseCode = "window.messageCallback('\(result)')"

            self.app?.evaluateJavaScript(jsonRpcResponseCode, completionHandler: { _, error in
                if let error = error {
                    AppKitLogger.e("[AppWebViewJsonRpcInterceptor] Error trying to inject JS, with error: \(error)")
                }
            })
        }
    }

    func respond(result: [AnyHashable: Any]) {
        DispatchQueue.main.async {
            guard let jsonString = result.jsonString() else { return }

            let jsonRpcResponseCode = "window.messageCallback('\(jsonString)')"

            self.app?.evaluateJavaScript(jsonRpcResponseCode, completionHandler: { _, error in
                if let error = error {
                    AppKitLogger.e("[AppWebViewJsonRpcInterceptor] Error trying to inject JS, with error: \(error)")
                }
            })
        }
    }

    func send(error: [String: String]) {
        var errorData = error
        errorData[MessageHandlerParam.statusCode.rawValue] = MessageHandlerStatusCode.internalError.rawValue
        sendError(errorData)
    }

    func send(error: MessageHandlerStatusCode) {
        sendError([MessageHandlerParam.error.rawValue: error.rawValue,
                   MessageHandlerParam.statusCode.rawValue: error.statusCode])
    }

    private func sendError(_ error: [AnyHashable: Any]) {
        AppKitLogger.e("[AppWebViewJsonRpcInterceptor] Sending error \(error)")

        DispatchQueue.main.async {
            guard let jsonString = error.jsonString() else { return }

            self.app?.evaluateJavaScript("window.messageCallback('\(jsonString)')", completionHandler: { _, error in
                if let error = error {
                    AppKitLogger.e("[AppWebViewJsonRpcInterceptor] Error trying to inject JS, with error: \(error)")
                }
            })
        }
    }
}
