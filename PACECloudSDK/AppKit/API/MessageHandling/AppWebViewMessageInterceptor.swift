//
//  AppWebViewMessageInterceptor.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation
import WebKit

class AppWebViewMessageInterceptor {
    enum MessageHandler: String, CaseIterable {
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
        case setUserProperty = "pace_setUserProperty"
        case logEvent = "pace_logEvent"
        case getConfig = "pace_getConfig"
    }

    private weak var app: App?

    init(app: App) {
        self.app = app
    }

    // swiftlint:disable cyclomatic_complexity
    func parseMessageRequest(message: WKScriptMessage) { // swiftlint:disable:this function_body_length
        guard let body = message.body as? String, let data = body.data(using: .utf8) else {
            send(id: "", error: .badRequest)
            return
        }

        switch message.name {
        case MessageHandler.close.rawValue:
            guard let request: AppKit.EmptyRequestData = decode(from: data) else {
                send(id: "", error: .badRequest)
                return
            }

            app?.handleCloseAction(with: request)

        case MessageHandler.getBiometricStatus.rawValue:
            guard let request: AppKit.EmptyRequestData = decode(from: data) else {
                send(id: "", error: .badRequest)
                return
            }

            app?.handleBiometryAvailabilityRequest(with: request)

        case MessageHandler.setTOTPSecret.rawValue:
            guard let request: AppKit.AppRequestData<AppKit.TOTPSecretData> = decode(from: data) else {
                handleBadRequestResponse(for: data)
                return
            }

            app?.setTOTPSecret(with: request, requestUrl: message.frameInfo.request.url)

        case MessageHandler.getTOTP.rawValue:
            guard let request: AppKit.AppRequestData<AppKit.GetTOTPData> = decode(from: data) else {
                handleBadRequestResponse(for: data)
                return
            }

            app?.getTOTP(with: request, requestUrl: message.frameInfo.request.url)

        case MessageHandler.setSecureData.rawValue:
            guard let request: AppKit.AppRequestData<AppKit.SetSecureData> = decode(from: data) else {
                handleBadRequestResponse(for: data)
                return
            }

            app?.setSecureData(with: request, requestUrl: message.frameInfo.request.url)

        case MessageHandler.getSecureData.rawValue:
            guard let request: AppKit.AppRequestData<AppKit.GetSecureData> = decode(from: data) else {
                handleBadRequestResponse(for: data)
                return
            }

            app?.getSecureData(with: request, requestUrl: message.frameInfo.request.url)

        case MessageHandler.disable.rawValue:
            guard let request: AppKit.AppRequestData<AppKit.DisableAction> = decode(from: data) else {
                handleBadRequestResponse(for: data)
                return
            }

            app?.handleDisableAction(with: request, requestUrl: message.frameInfo.request.url)

        case MessageHandler.openURLInNewTab.rawValue:
            guard let request: AppKit.AppRequestData<AppKit.OpenUrlInNewTabData> = decode(from: data) else {
                handleBadRequestResponse(for: data)
                return
            }

            app?.handleOpenURLInNewTabAction(with: request, requestUrl: message.frameInfo.request.url)

        case MessageHandler.invalidToken.rawValue:
            guard let request: AppKit.AppRequestData<AppKit.InvalidTokenData> = decode(from: data) else {
                handleBadRequestResponse(for: data)
                return
            }

            app?.handleInvalidTokenRequest(with: request)

        case MessageHandler.imageData.rawValue:
            guard let request: AppKit.AppRequestData<String> = decode(from: data) else {
                handleBadRequestResponse(for: data)
                return
            }

            app?.handleImageDataRequest(with: request)

        case MessageHandler.applePayAvailabilityCheck.rawValue:
            guard let request: AppKit.AppRequestData<String> = decode(from: data) else {
                handleBadRequestResponse(for: data)
                return
            }

            app?.handleApplePayAvailibilityCheck(with: request)

        case MessageHandler.applePayRequest.rawValue:
            guard let request: AppKit.AppRequestData<AppKit.ApplePayRequest> = decode(from: data) else {
                handleBadRequestResponse(for: data)
                return
            }

            app?.handleApplePayPaymentRequest(with: request)

        case MessageHandler.verifyLocation.rawValue:
            guard let request: AppKit.AppRequestData<AppKit.VerifyLocationData> = decode(from: data) else {
                handleBadRequestResponse(for: data)
                return
            }

            app?.handleVerifyLocationRequest(with: request)

        case MessageHandler.logger.rawValue:
            app?.handleLog(with: body)

        case MessageHandler.back.rawValue:
            guard let request: AppKit.EmptyRequestData = decode(from: data) else {
                send(id: "", error: .badRequest)
                return
            }

            app?.handleBack(with: request)

        case MessageHandler.redirectScheme.rawValue:
            guard let request: AppKit.EmptyRequestData = decode(from: data) else {
                send(id: "", error: .badRequest)
                return
            }

            app?.handleRedirectScheme(with: request)

        case MessageHandler.setUserProperty.rawValue:
            guard let request: AppKit.AppRequestData<AppKit.SetUserPropertyData> = decode(from: data) else {
                handleBadRequestResponse(for: data)
                return
            }

            app?.handleSetUserProperty(with: request)

        case MessageHandler.logEvent.rawValue:
            guard let request: AppKit.AppRequestData<AppKit.LogEventData> = decode(from: data) else {
                handleBadRequestResponse(for: data)
                return
            }

            app?.handleLogEvent(with: request)

        case MessageHandler.getConfig.rawValue:
            guard let request: AppKit.AppRequestData<AppKit.GetConfigData> = decode(from: data) else {
                handleBadRequestResponse(for: data)
                return
            }

            app?.handleGetConfig(with: request)

        default:
            guard let request: AppKit.EmptyRequestData = decode(from: data) else {
                send(id: "", error: .badRequest)
                return
            }

            send(id: request.id, error: .badRequest)
        }
    }

    private func handleBadRequestResponse(for data: Data) {
        if let request = try? JSONDecoder().decode(AppKit.EmptyRequestData.self, from: data) {
            send(id: request.id, error: .badRequest)
        } else {
            send(id: "", error: .badRequest)
        }
    }

    private func decode<T: Decodable>(from data: Data) -> T? {
        let request = try? JSONDecoder().decode(T.self, from: data)
        return request
    }

    private func respond(result: String) {
        DispatchQueue.main.async {
            let messageResponse = "window.postMessage('\(result)', window.origin)"

            self.app?.evaluateJavaScript(messageResponse, completionHandler: { _, error in
                if let error = error {
                    AppKitLogger.e("[AppWebViewMessageInterceptor] Error trying to inject JS, with error: \(error)")
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
        AppKitLogger.e("[AppWebViewMessageInterceptor] Sending error \(error)")

        DispatchQueue.main.async {
            guard let jsonString = error.jsonString() else { return }

            self.app?.evaluateJavaScript("window.postMessage('\(jsonString)', window.origin)", completionHandler: { _, error in
                if let error = error {
                    AppKitLogger.e("[AppWebViewMessageInterceptor] Error trying to inject JS, with error: \(error)")
                }
            })
        }
    }
}
