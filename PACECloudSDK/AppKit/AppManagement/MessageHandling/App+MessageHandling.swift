//
//  App+MessageHandling.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation
import UIKit

// MARK: - Message handling
extension App {
    func handleLog(with message: String) {
        AppKitLogger.pwa(message)
    }

    func handleClose(completion: @escaping (API.Communication.CloseResult) -> Void) {
        performClose()
        completion(.init(.init()))
    }

    func performClose() {
        DispatchQueue.main.async { [weak self] in
            guard let appActionsDelegate = self?.appActionsDelegate else {
                // WebView directly added to client's view
                self?.removeFromSuperview()
                return
            }

            // WebView opened in view controller
            appActionsDelegate.appRequestedCloseAction() // Close AppViewController if available
        }
    }

    func handleLogout(completion: @escaping (API.Communication.LogoutResult) -> Void) {
        AppKit.shared.notifyLogout { response in
            if response.statusCode == .okNoContent {
                completion(.init(.init()))
            } else if response.statusCode == .notFound {
                completion(.init(.init(statusCode: .notFound, response: .init(message: "The user wasn't logged in."))))
            } else {
                completion(.init(.init(statusCode: .internalServerError, response: .init(message: "Client did respond with status code \(response.statusCode.rawValue)."))))
            }
        }
    }

    func handleDisable(with request: API.Communication.DisableRequest, requestUrl: URL?, completion: @escaping (API.Communication.DisableResult) -> Void) {
        guard let host = requestUrl?.host else {
            completion(.init(.init(statusCode: .badRequest, response: .init(message: "The request url couldn't be retrieved."))))
            return
        }

        let untilTime = request.until

        // Persist disable's until date
        AppKitLogger.i("[App] Set disable timer for \(host): \(untilTime)")
        UserDefaults.standard.set(untilTime, forKey: "disable_time_\(host)")

        // Close App after everything has been set
        guard let appActionsDelegate = appActionsDelegate else {
            // WebView directly added to client's view
            self.removeFromSuperview()
            return
        }

        // WebView opened in view controller
        appActionsDelegate.appRequestedDisableAction(for: host)
        completion(.init(.init()))
    }

    func handleOpenURLInNewTab(with request: API.Communication.OpenURLInNewTabRequest, requestUrl: URL?, completion: @escaping (API.Communication.OpenURLInNewTabResult) -> Void) {
        guard let sourceUrl = requestUrl else {
            completion(.init(.init(statusCode: .badRequest, response: .init(message: "The request url couldn't be retrieved."))))
            return
        }

        guard let appActionsDelegate = appActionsDelegate else {
            completion(.init(.init(statusCode: .internalServerError, response: .init(message: "Couldn't find the delegate to handle this message."))))
            return
        }

        guard let cancelUrl = URL(string: request.cancelUrl) else {
            completion(.init(.init(statusCode: .badRequest, response: .init(message: "The value for 'cancelUrl' is not a valid url."))))
            AppKit.shared.notifyDidFail(with: .badRequest)
            load(URLRequest(url: sourceUrl))
            return
        }

        guard let customScheme = Bundle.main.clientRedirectScheme, let customUrl = URL(string: "\(customScheme)://") else {
            AppKit.shared.notifyDidFail(with: .customURLSchemeNotSet)
            completion(.init(.init(statusCode: .internalServerError,
                                   response: .init(message: "Either the client's redirect scheme couldn't be retrieved or the scheme is not a valid url."))))
            load(URLRequest(url: cancelUrl))

            return
        }

        if UIApplication.shared.canOpenURL(customUrl) {
            appActionsDelegate.appRequestedNewTab(for: request.url, cancelUrl: cancelUrl.absoluteString)
            completion(.init(.init()))
        } else {
            completion(.init(.init(statusCode: .methodNotAllowed, response: .init(message: "The scheme cannot be opened by the client app."))))
            AppKit.shared.notifyDidFail(with: .customURLSchemeNotSet)
            load(URLRequest(url: cancelUrl))
        }
    }

    func handleImageData(with request: API.Communication.ImageDataRequest, completion: @escaping (API.Communication.ImageDataResult) -> Void) {
        guard let decodedData = Data(base64Encoded: request.image),
              let image = UIImage(data: decodedData) else {
            AppKitLogger.e("[App] Could not decode base64 string")
            completion(.init(.init(statusCode: .internalServerError, response: .init(message: "The value for 'image' couldn't be converted into an image."))))
            return
        }

        AppKit.shared.notifyImageData(with: image)
        completion(.init(.init()))
    }

    func handleBack(completion: @escaping (API.Communication.BackResult) -> Void) {
        if backForwardList.backItem == nil {
            performClose()
            completion(.init(.init()))
        } else {
            goBack()
            completion(.init(.init()))
        }
    }

    func handleAppInterceptableLink(completion: @escaping (API.Communication.AppInterceptableLinkResult) -> Void) {
        guard let customScheme = Bundle.main.clientRedirectScheme else {
            completion(.init(.init(statusCode: .notFound, response: .init(message: "The client's redirect scheme couldn't be retrieved."))))
            AppKit.shared.notifyDidFail(with: .customURLSchemeNotSet)
            return
        }

        completion(.init(.init(response: .init(link: customScheme))))
    }

    func handleSetUserProperty(with request: API.Communication.SetUserPropertyRequest, completion: @escaping (API.Communication.SetUserPropertyResult) -> Void) {
        let key = request.key
        let value = request.value
        let update = request.update ?? false
        AppKit.shared.notifySetUserProperty(key: key, value: value, update: update)
        completion(.init(.init()))
    }

    func handleLogEvent(with request: API.Communication.LogEventRequest, completion: @escaping (API.Communication.LogEventResult) -> Void) {
        let key = request.key
        let parameters: [String: Any] = request.parameters?.reduce(into: [:], { $0[$1.key] = $1.value.value }) ?? [:]
        AppKit.shared.notifyLogEvent(key: key, parameters: parameters)
        completion(.init(.init()))
    }

    func handleGetConfig(with request: API.Communication.GetConfigRequest, completion: @escaping (API.Communication.GetConfigResult) -> Void) {
        let key = request.key
        AppKit.shared.notifyGetConfig(key: key) { value in
            guard let value = value else {
                completion(.init(.init(statusCode: .notFound, response: .init(message: "The config value for the given key couldn't be retrieved."))))
                return
            }
            completion(.init(.init(response: .init(value: "\(value)"))))
        }
    }

    func handleGetTraceId(completion: @escaping (API.Communication.GetTraceIdResult) -> Void) {
        guard let traceId = PACECloudSDK.shared.traceId else {
            completion(.init(.init(statusCode: .internalServerError, response: .init(message: "The trace id couldn't be retrieved."))))
            return
        }
        completion(.init(.init(response: .init(value: traceId))))
    }

    func handleAppRedirect(with request: API.Communication.AppRedirectRequest, completion: @escaping (API.Communication.AppRedirectResult) -> Void) {
        // TODO Handle app redirect
        completion(.init(.init(statusCode: .internalServerError, response: .init(message: "Not yet implemented."))))
    }

    func respond(with response: String) {
        respond(result: response)
    }
}
