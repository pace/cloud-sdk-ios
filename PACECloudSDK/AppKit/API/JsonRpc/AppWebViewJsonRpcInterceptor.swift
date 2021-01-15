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
        case invalidToken = "pace_invalidToken"
        case imageData = "pace_imageData"
        case applePayAvailabilityCheck = "pace_applePayAvailabilityCheck"
        case applePayRequest = "pace_applePayRequest"
        case verifyLocation = "pace_verifyLocation"
    }

    private weak var app: App?

    init(app: App) {
        self.app = app
    }

    func parseJsonRpcRequest(message: WKScriptMessage) {
        guard let app = app else { return }

        switch message.name {
        case JsonRpcHandler.invalidToken.rawValue:
            app.handleInvalidTokenRequest()

        case JsonRpcHandler.imageData.rawValue:
            app.handleImageDataRequest(with: message)

        case JsonRpcHandler.applePayAvailabilityCheck.rawValue:
            app.handleApplePayAvailibilityCheck(with: message)

        case JsonRpcHandler.applePayRequest.rawValue:
            app.handleApplePayPaymentRequest(with: message)

        case JsonRpcHandler.verifyLocation.rawValue:
            app.handleVerifyLocationRequest(with: message)

        default:
            send(error: buildErrorObject(code: JsonRpcErrorObjects.methodNotFound.code, message: JsonRpcErrorObjects.methodNotFound.message))
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

    func send(error: [AnyHashable: Any]) {
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

    func buildErrorObject(code: Int, message: String) -> [AnyHashable: Any] {
        return ErrorObject(code: code, message: message, data: EmptyJSONObject()).dictionary ?? [:]
    }
}
