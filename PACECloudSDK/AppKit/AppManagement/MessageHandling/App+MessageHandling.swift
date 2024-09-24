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
        AppKitLogger.d("[PWA] \(message)")
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
        AppKitLogger.d("[App] Set disable timer for \(host): \(untilTime)")
        SDKUserDefaults.set(untilTime, for: "disable_time_\(host)", isUserSensitiveData: false)

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

        // If integrated is true, do not check if PACE redirect scheme is set but always load the URL in the webview
        if let integrated = request.integrated, integrated {
            appActionsDelegate.appRequestedNewTab(for: request.url, cancelUrl: cancelUrl.absoluteString, integrated: integrated)
            completion(.init(.init()))
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
            appActionsDelegate.appRequestedNewTab(for: request.url, cancelUrl: cancelUrl.absoluteString, integrated: request.integrated ?? false)
            completion(.init(.init()))
        } else {
            completion(.init(.init(statusCode: .methodNotAllowed, response: .init(message: "The scheme cannot be opened by the client app."))))
            AppKit.shared.notifyDidFail(with: .customURLSchemeNotSet)
            load(URLRequest(url: cancelUrl))
        }
    }

    func handleImageData(with request: API.Communication.ImageDataRequest, completion: @escaping (API.Communication.ImageDataResult) -> Void) {
        guard let decodedData = Data(base64Encoded: request.image) else {
            AppKitLogger.e("[App] Could not decode base64 string into data - imageData")
            completion(.init(.init(statusCode: .badRequest, response: .init(message: "The value for 'image' couldn't be decoded."))))
            return
        }

        if handleShareImage(of: decodedData) {
            completion(.init(.init()))
        } else {
            AppKitLogger.e("[App] Could not decode base64 string - imageData")
            completion(.init(.init(statusCode: .badRequest, response: .init(message: "The value for 'image' couldn't be converted into an image."))))
        }
    }

    func handleShareText(with request: API.Communication.ShareTextRequest, completion: @escaping (API.Communication.ShareTextResult) -> Void) {
        AppKit.shared.notifyDidReceiveText(title: request.title, text: request.text)
        completion(.init(.init()))
    }

    func handleShareFile(with request: API.Communication.ShareFileRequest, completion: @escaping (API.Communication.ShareFileResult) -> Void) {
        guard let decodedData = Data(base64Encoded: request.payload) else {
            AppKitLogger.e("[App] Could not decode base64 string into data - shareFile")
            completion(.init(.init(statusCode: .badRequest, response: .init(message: "The value for 'payload' couldn't be decoded."))))
            return
        }

        switch request.fileExtension {
        case "png":
            if handleShareImage(of: decodedData) {
                completion(.init(.init()))
            } else {
                AppKitLogger.e("[App] Could not decode base64 string into image - shareFile")
                completion(.init(.init(statusCode: .badRequest, response: .init(message: "The value for 'payload' couldn't be converted into an image."))))
            }

        case "pdf":
            AppKit.shared.notifyShareFile(data: decodedData)
            completion(.init(.init()))

        default:
            completion(.init(.init(statusCode: .methodNotAllowed, response: .init(message: "Unsupported file extension"))))
        }
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

        var context: [String: Any] = [:]
        if request.context != nil {
            context = request.context!.reduce(into: [:], { $0[$1.key] = $1.value.value })
        }

        AppKit.shared.notifyLogEvent(key: key, parameters: parameters, context: context)
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
        AppKit.shared.notifyIsAppRedirectAllowed(app: request.app) { isAllowed in
            if isAllowed {
                completion(.init(.init()))
            } else {
                self.performClose()
                completion(.init(.init(statusCode: .methodNotAllowed, response: .init(message: "The app redirect is not allowed."))))
            }
        }
    }

    func respond(with response: String) {
        respond(result: response)
    }

    func handleIsRemoteConfigAvailable(completion: @escaping (API.Communication.IsRemoteConfigAvailableResult) -> Void) {
        AppKit.shared.notifyIsRemoteConfigAvailable { isAvailable in
            completion(.init(.init(response: .init(remoteConfigAvailable: isAvailable))))
        }
    }

    func handleStartNavigation(with request: API.Communication.StartNavigationRequest,
                               completion: @escaping (API.Communication.StartNavigationResult) -> Void) {
        AppKit.shared.notifyStartNavigation(request: request) { isSuccessful in
            if isSuccessful {
                completion(.init(.init()))
            } else {
                completion(.init(.init(statusCode: .internalServerError, response: .init(message: "Failed starting navigation by client"))))
            }
        }
    }

    func handleReceiptEmail(with request: API.Communication.ReceiptEmailRequest, completion: @escaping (API.Communication.ReceiptEmailResult) -> Void) {
        AppKit.shared.notifyGetReceiptEmail(request: request) { email in
            completion(.init(.init(response: .init(email: email))))
        }
    }

    func handleReceiptAttachments(with request: API.Communication.ReceiptAttachmentsRequest, completion: @escaping (API.Communication.ReceiptAttachmentsResult) -> Void) {
        AppKit.shared.notifyGetReceiptAttachments(request: request) { attachments in
            completion(.init(.init(response: .init(attachments: attachments))))
        }
    }
}

private extension App {
    func handleShareImage(of data: Data) -> Bool {
        guard let image = UIImage(data: data) else {
            AppKitLogger.e("[App] Could not decode base64 string into image - shareFile")
            return false
        }

        AppKit.shared.notifyImageData(with: image)
        return true
    }
}
