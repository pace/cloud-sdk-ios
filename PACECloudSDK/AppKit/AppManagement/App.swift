//
//  AppBase.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import CoreLocation
import Foundation
import PassKit
import WebKit

protocol App: WKWebView, WKScriptMessageHandler, SecureDataCommunication {
    var appUrl: String? { get }
    var placeholder: NoNetworkPlaceholderView { get set }
    var loadingView: LoadingView { get }
    var successfullyLoadedOnce: Bool { get set }
    var webViewDelegate: AppWebViewDelegate? { get }
    var messageInterceptor: AppWebViewMessageInterceptor? { get }
    var appActionsDelegate: AppActionsDelegate? { get set }
    var oneTimeLocationProvider: OneTimeLocationProvider { get }
}

extension App {
    func loadUrl(urlString: String?, cookies: [HTTPCookie] = []) {
        guard let urlString = urlString,
            let url = URL(string: urlString) else {
            AppKitLogger.e("[App] Can't load app url - url is nil")
            AppKit.shared.notifyDidFail(with: .failedRetrievingUrl)
            return
        }

        // Add additional query parameter to request, if applicable
        guard let utmUrl = QueryParamHandler.buildUrl(for: url) else {
            AppKitLogger.e("[App] Can't load component url")
            AppKit.shared.notifyDidFail(with: .failedRetrievingUrl)
            return
        }

        load(URLRequest(url: utmUrl, withTracingId: true), with: cookies)
    }

    func load(_ request: URLRequest, with cookies: [HTTPCookie]) {
        var request = request
        let headers = HTTPCookie.requestHeaderFields(with: cookies)

        for (name, value) in headers {
            request.addValue(value, forHTTPHeaderField: name)
        }

        load(request)
    }

    func showErrorState() {
        placeholder.isHidden = false
        loadingView.isLoading = false
        loadingView.isHidden = true
    }

    func decode<T: Decodable>(from data: Data) -> T? {
        let request = try? JSONDecoder().decode(T.self, from: data)
        return request
    }

    func handle(_ messageHandler: MessageHandler, with data: Data, requestUrl: URL?) { // swiftlint:disable:this cyclomatic_complexity function_body_length
        if messageHandler == .logger {
            guard let log = String(data: data, encoding: .utf8) else { return }
            handleLog(with: log)
            return // Don't schedule a timer for this request
        }

        guard let requestId: String = try? JSONDecoder().decode(AppKit.EmptyRequestData.self, from: data).id else {
            messageInterceptor?.send(id: "", error: .badRequest)
            return
        }

        let messageExecution: (@escaping () -> Void) -> Void

        switch messageHandler {
        case .close:
            guard let request: AppKit.EmptyRequestData = decode(from: data) else {
                messageInterceptor?.send(id: "", error: .badRequest)
                return
            }

            messageExecution = { [weak self] completion in
                self?.handleCloseAction(with: request)
                completion()
            }

        case .getBiometricStatus:
            guard let request: AppKit.EmptyRequestData = decode(from: data) else {
                messageInterceptor?.send(id: "", error: .badRequest)
                return
            }

            messageExecution = { [weak self] completion in
                self?.handleBiometryAvailabilityRequest(with: request)
                completion()
            }

        case .setTOTPSecret:
            guard let request: AppKit.AppRequestData<AppKit.TOTPSecretData> = decode(from: data) else {
                handleBadRequestResponse(for: data)
                return
            }

            messageExecution = { [weak self] completion in
                self?.setTOTPSecret(with: request, requestUrl: requestUrl, completion: completion)
            }

        case .getTOTP:
            guard let request: AppKit.AppRequestData<AppKit.GetTOTPData> = decode(from: data) else {
                handleBadRequestResponse(for: data)
                return
            }

            messageExecution = { [weak self] completion in
                self?.getTOTP(with: request, requestUrl: requestUrl, completion: completion)
            }

        case .setSecureData:
            guard let request: AppKit.AppRequestData<AppKit.SetSecureData> = decode(from: data) else {
                handleBadRequestResponse(for: data)
                return
            }

            messageExecution = { [weak self] completion in
                self?.setSecureData(with: request, requestUrl: requestUrl)
                completion()
            }

        case .getSecureData:
            guard let request: AppKit.AppRequestData<AppKit.GetSecureData> = decode(from: data) else {
                handleBadRequestResponse(for: data)
                return
            }

            messageExecution = { [weak self] completion in
                self?.getSecureData(with: request, requestUrl: requestUrl, completion: completion)
            }

        case .disable:
            guard let request: AppKit.AppRequestData<AppKit.DisableAction> = decode(from: data) else {
                handleBadRequestResponse(for: data)
                return
            }

            messageExecution = { [weak self] completion in
                self?.handleDisableAction(with: request, requestUrl: requestUrl)
                completion()
            }

        case .openURLInNewTab:
            guard let request: AppKit.AppRequestData<AppKit.OpenUrlInNewTabData> = decode(from: data) else {
                handleBadRequestResponse(for: data)
                return
            }

            messageExecution = { [weak self] completion in
                self?.handleOpenURLInNewTabAction(with: request, requestUrl: requestUrl)
                completion()
            }

        case .getAccessToken:
            guard let request: AppKit.AppRequestData<AppKit.GetAccessTokenData> = decode(from: data) else {
                handleBadRequestResponse(for: data)
                return
            }

            messageExecution = { [weak self] completion in
                self?.handleGetAccessTokenRequest(with: request, completion: completion)
            }

        case .logout:
            guard let request: AppKit.EmptyRequestData = decode(from: data) else {
                handleBadRequestResponse(for: data)
                return
            }

            messageExecution = { [weak self] completion in
                self?.handleLogout(with: request, completion: completion)
            }

        case .imageData:
            guard let request: AppKit.AppRequestData<String> = decode(from: data) else {
                handleBadRequestResponse(for: data)
                return
            }

            messageExecution = { [weak self] completion in
                self?.handleImageDataRequest(with: request)
                completion()
            }

        case .applePayAvailabilityCheck:
            guard let request: AppKit.AppRequestData<String> = decode(from: data) else {
                handleBadRequestResponse(for: data)
                return
            }

            messageExecution = { [weak self] completion in
                self?.handleApplePayAvailibilityCheck(with: request)
                completion()
            }

        case .applePayRequest:
            guard let request: AppKit.AppRequestData<AppKit.ApplePayRequest> = decode(from: data) else {
                handleBadRequestResponse(for: data)
                return
            }

            messageExecution = { [weak self] completion in
                self?.handleApplePayPaymentRequest(with: request, completion: completion)
            }

        case .verifyLocation:
            guard let request: AppKit.AppRequestData<AppKit.VerifyLocationData> = decode(from: data) else {
                handleBadRequestResponse(for: data)
                return
            }

            messageExecution = { [weak self] completion in
                self?.handleVerifyLocationRequest(with: request, completion: completion)
            }

        case .back:
            guard let request: AppKit.EmptyRequestData = decode(from: data) else {
                messageInterceptor?.send(id: "", error: .badRequest)
                return
            }

            messageExecution = { [weak self] completion in
                self?.handleBack(with: request)
                completion()
            }

        case .redirectScheme:
            guard let request: AppKit.EmptyRequestData = decode(from: data) else {
                messageInterceptor?.send(id: "", error: .badRequest)
                return
            }

            messageExecution = { [weak self] completion in
                self?.handleRedirectScheme(with: request)
                completion()
            }

        case .setUserProperty:
            guard let request: AppKit.AppRequestData<AppKit.SetUserPropertyData> = decode(from: data) else {
                handleBadRequestResponse(for: data)
                return
            }

            messageExecution = { [weak self] completion in
                self?.handleSetUserProperty(with: request)
                completion()
            }

        case .logEvent:
            guard let request: AppKit.AppRequestData<AppKit.LogEventData> = decode(from: data) else {
                handleBadRequestResponse(for: data)
                return
            }

            messageExecution = { [weak self] completion in
                self?.handleLogEvent(with: request)
                completion()
            }

        case .getConfig:
            guard let request: AppKit.AppRequestData<AppKit.GetConfigData> = decode(from: data) else {
                handleBadRequestResponse(for: data)
                return
            }

            messageExecution = { [weak self] completion in
                self?.handleGetConfig(with: request, completion: completion)
            }

        case .getTraceId:
            guard let request: AppKit.EmptyRequestData = decode(from: data) else {
                messageInterceptor?.send(id: "", error: .badRequest)
                return
            }

            messageExecution = { [weak self] completion in
                self?.handleGetTraceId(with: request)
                completion()
            }

        default:
            handleBadRequestResponse(for: data)
            return
        }

        AppKit.shared.requestTimeoutHandler
            .scheduleTimer(for: requestId,
                           timeout: messageHandler.timeout,
                           messageInterceptor: messageInterceptor,
                           requestHandler: { (completion: @escaping () -> Void) in
                            messageExecution(completion)
                           })
    }

    private func handleBadRequestResponse(for data: Data) {
        if let request: AppKit.EmptyRequestData = decode(from: data) {
            messageInterceptor?.send(id: request.id, error: .badRequest)
        } else {
            messageInterceptor?.send(id: "", error: .badRequest)
        }
    }
}
