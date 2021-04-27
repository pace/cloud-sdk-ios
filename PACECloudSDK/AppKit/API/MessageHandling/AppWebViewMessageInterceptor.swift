//
//  AppWebViewMessageInterceptor.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation
import WebKit

class AppWebViewMessageInterceptor {
    private weak var app: App?

    init(app: App) {
        self.app = app
    }

    func parseMessageRequest(message: WKScriptMessage) {
        guard let body = message.body as? String,
              let data = body.data(using: .utf8) else {
            send(id: "", error: .badRequest)
            return
        }

        guard let messageHandler = MessageHandler(rawValue: message.name) else {
            guard let request: AppKit.EmptyRequestData = app?.decode(from: data) else {
                send(id: "", error: .badRequest)
                return
            }

            send(id: request.id, error: .badRequest)
            return
        }

        app?.handle(messageHandler, with: data, requestUrl: message.frameInfo.request.url)
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
