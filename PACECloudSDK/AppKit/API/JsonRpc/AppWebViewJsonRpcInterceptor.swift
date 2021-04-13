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
        case redirectScheme = "pace_getAppInterceptableLink"
    }

    private weak var app: App?

    init(app: App) {
        self.app = app
    }

    // swiftlint:disable cyclomatic_complexity
    func parseJsonRpcRequest(message: WKScriptMessage) { // swiftlint:disable:this function_body_length
        guard let body = message.body as? String, let data = body.data(using: .utf8) else {
            send(id: "", error: .badRequest)
            return
        }

        switch message.name {
        case JsonRpcHandler.close.rawValue:
            guard let request = try? JSONDecoder().decode(AppKit.EmptyRequestData.self, from: data) else {
                send(id: "", error: .badRequest)
                return
            }

            app?.handleCloseAction(with: request)

        case JsonRpcHandler.getBiometricStatus.rawValue:
            guard let request = try? JSONDecoder().decode(AppKit.EmptyRequestData.self, from: data) else {
                send(id: "", error: .badRequest)
                return
            }

            app?.handleBiometryAvailabilityRequest(with: request)

        case JsonRpcHandler.setTOTPSecret.rawValue:
            guard let request = try? JSONDecoder().decode(AppKit.AppRequestData<AppKit.TOTPSecretData>.self, from: data) else {
                send(id: "", error: .badRequest)
                return
            }

            app?.setTOTPSecret(with: request, requestUrl: message.frameInfo.request.url)

        case JsonRpcHandler.getTOTP.rawValue:
            guard let request = try? JSONDecoder().decode(AppKit.AppRequestData<AppKit.GetTOTPData>.self, from: data) else {
                send(id: "", error: .badRequest)
                return
            }

            app?.getTOTP(with: request, requestUrl: message.frameInfo.request.url)

        case JsonRpcHandler.setSecureData.rawValue:
            guard let request = try? JSONDecoder().decode(AppKit.AppRequestData<AppKit.SetSecureData>.self, from: data) else {
                send(id: "", error: .badRequest)
                return
            }

            app?.setSecureData(with: request, requestUrl: message.frameInfo.request.url)

        case JsonRpcHandler.getSecureData.rawValue:
            guard let request = try? JSONDecoder().decode(AppKit.AppRequestData<AppKit.GetSecureData>.self, from: data) else {
                send(id: "", error: .badRequest)
                return
            }

            app?.getSecureData(with: request, requestUrl: message.frameInfo.request.url)

        case JsonRpcHandler.disable.rawValue:
            guard let request = try? JSONDecoder().decode(AppKit.AppRequestData<AppKit.DisableAction>.self, from: data) else {
                send(id: "", error: .badRequest)
                return
            }

            app?.handleDisableAction(with: request, requestUrl: message.frameInfo.request.url)

        case JsonRpcHandler.openURLInNewTab.rawValue:
            guard let request = try? JSONDecoder().decode(AppKit.AppRequestData<AppKit.OpenUrlInNewTabData>.self, from: data) else {
                send(id: "", error: .badRequest)
                return
            }

            app?.handleOpenURLInNewTabAction(with: request, requestUrl: message.frameInfo.request.url)

        case JsonRpcHandler.invalidToken.rawValue:
            guard let request = try? JSONDecoder().decode(AppKit.AppRequestData<AppKit.InvalidTokenData>.self, from: data) else {
                send(id: "", error: .badRequest)
                return
            }

            app?.handleInvalidTokenRequest(with: request)

        case JsonRpcHandler.imageData.rawValue:
            guard let request = try? JSONDecoder().decode(AppKit.AppRequestData<String>.self, from: data) else {
                send(id: "", error: .badRequest)
                return
            }

            app?.handleImageDataRequest(with: request)

        case JsonRpcHandler.applePayAvailabilityCheck.rawValue:
            guard let request = try? JSONDecoder().decode(AppKit.AppRequestData<String>.self, from: data) else {
                send(id: "", error: .badRequest)
                return
            }

            app?.handleApplePayAvailibilityCheck(with: request)

        case JsonRpcHandler.applePayRequest.rawValue:
            guard let request = try? JSONDecoder().decode(AppKit.AppRequestData<AppKit.ApplePayRequest>.self, from: data) else {
                send(id: "", error: .badRequest)
                return
            }

            app?.handleApplePayPaymentRequest(with: request)

        case JsonRpcHandler.verifyLocation.rawValue:
            guard let request = try? JSONDecoder().decode(AppKit.AppRequestData<AppKit.VerifyLocationData>.self, from: data) else {
                send(id: "", error: .badRequest)
                return
            }

            app?.handleVerifyLocationRequest(with: request)

        case JsonRpcHandler.logger.rawValue:
            app?.handleLog(with: body)

        case JsonRpcHandler.back.rawValue:
            guard let request = try? JSONDecoder().decode(AppKit.EmptyRequestData.self, from: data) else {
                send(id: "", error: .badRequest)
                return
            }

            app?.handleBack(with: request)

        case JsonRpcHandler.redirectScheme.rawValue:
            guard let request = try? JSONDecoder().decode(AppKit.EmptyRequestData.self, from: data) else {
                send(id: "", error: .badRequest)
                return
            }

            app?.handleRedirectScheme(with: request)

        default:
            guard let request = try? JSONDecoder().decode(AppKit.EmptyRequestData.self, from: data) else {
                send(id: "", error: .badRequest)
                return
            }

            send(id: request.id, error: .badRequest)
        }
    }

    private func respond(result: String) {
        DispatchQueue.main.async {
            let jsonRpcResponseCode = "window.postMessage('\(result)', window.origin)"

            self.app?.evaluateJavaScript(jsonRpcResponseCode, completionHandler: { _, error in
                if let error = error {
                    AppKitLogger.e("[AppWebViewJsonRpcInterceptor] Error trying to inject JS, with error: \(error)")
                }
            })
        }
    }

    func respond(id: String, message: Any) {
        guard let response = ["id": id, "message": message].jsonString() else { return }

        respond(result: response)
    }

    func respond(id: String, statusCode: HttpStatusCode) {
        respond(id: id, message: [MessageHandlerParam.statusCode.rawValue: statusCode.rawValue])
    }

    func send(id: String, error: [String: String]) {
        var message = error
        message[MessageHandlerParam.statusCode.rawValue] = MessageHandlerStatusCode.internalError.rawValue
        let errorData: [String: Any] = ["id": id, "message": message]
        sendError(errorData)
    }

    func send(id: String, error: MessageHandlerStatusCode) {
        let errorMessage: [AnyHashable: Any] = [
            "id": id,
            "message": [MessageHandlerParam.error.rawValue: error.rawValue,
                        MessageHandlerParam.statusCode.rawValue: error.statusCode]
        ]

        sendError(errorMessage)
    }

    private func sendError(_ error: [AnyHashable: Any]) {
        AppKitLogger.e("[AppWebViewJsonRpcInterceptor] Sending error \(error)")

        DispatchQueue.main.async {
            guard let jsonString = error.jsonString() else { return }

            self.app?.evaluateJavaScript("window.postMessage('\(jsonString)', window.origin)", completionHandler: { _, error in
                if let error = error {
                    AppKitLogger.e("[AppWebViewJsonRpcInterceptor] Error trying to inject JS, with error: \(error)")
                }
            })
        }
    }
}
