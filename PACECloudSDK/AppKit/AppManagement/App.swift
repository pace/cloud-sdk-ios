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
    var jsonRpcInterceptor: AppWebViewJsonRpcInterceptor? { get }
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

        load(URLRequest(url: utmUrl), with: cookies)
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
}

// MARK: - Message handling
extension App {
    func handleCloseAction(with message: WKScriptMessage) {
        guard let appActionsDelegate = appActionsDelegate else {
            // WebView directly added to client's view
            self.removeFromSuperview()
            return
        }

        // WebView opened in view controller
        appActionsDelegate.appRequestedCloseAction() // Close AppViewController if available
    }

    func handleDisableAction(with message: WKScriptMessage) {
        guard let body = message.body as? String,
              let host = message.frameInfo.request.url?.host else {
            jsonRpcInterceptor?.send(error: .badRequest)
            return
        }

        var disableMessageData: [String: AnyHashable]?

        do {
            disableMessageData = try JSONSerialization.jsonObject(with: Data(body.utf8), options: []) as? [String: AnyHashable]

        } catch {
            jsonRpcInterceptor?.send(error: ["error": "\(error.localizedDescription)"])
            return
        }

        guard let untilTime = disableMessageData?[MessageHandlerParam.until.rawValue] as? Double else {
            jsonRpcInterceptor?.send(error: .badRequest)
            return
        }

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
    }

    func handleOpenURLInNewTabAction(with message: WKScriptMessage) {
        guard let body = message.body as? String,
              let sourceUrl = message.frameInfo.request.url else {
            jsonRpcInterceptor?.send(error: .badRequest)
            return
        }

        guard let appActionsDelegate = appActionsDelegate else { return }

        var openInTabMessageData: [String: String]?

        do {
            openInTabMessageData = try JSONSerialization.jsonObject(with: Data(body.utf8), options: []) as? [String: String]
        } catch {
            jsonRpcInterceptor?.send(error: ["error": "\(error.localizedDescription)"])
            return
        }

        guard let url: String = openInTabMessageData?[MessageHandlerParam.url.rawValue],
              let cancelUrlString: String = openInTabMessageData?[MessageHandlerParam.cancelUrl.rawValue],
              let cancelUrl = URL(string: cancelUrlString) else {
            jsonRpcInterceptor?.send(error: .badRequest)
            AppKit.shared.notifyDidFail(with: .badRequest)
            load(URLRequest(url: sourceUrl))
            return
        }

        guard let clientId = PACECloudSDK.shared.clientId, let customScheme = URL(string: "pace.\(clientId)://") else {
            AppKit.shared.notifyDidFail(with: .customURLSchemeNotSet)

            load(URLRequest(url: cancelUrl))

            return
        }

        if UIApplication.shared.canOpenURL(customScheme) {
            appActionsDelegate.appRequestedNewTab(for: url, cancelUrl: cancelUrl.absoluteString)
        } else {
            AppKit.shared.notifyDidFail(with: .customURLSchemeNotSet)

            load(URLRequest(url: cancelUrl))
        }
    }

    func handleInvalidTokenRequest() {
        guard PACECloudSDK.shared.authenticationMode == .native else { return }

        AppKit.shared.notifyInvalidToken { [weak self] token in
            if TokenValidator.isTokenValid(token) {
                PACECloudSDK.shared.currentAccessToken = token
                self?.jsonRpcInterceptor?.respond(result: token)
            } else {
                self?.handleInvalidTokenRequest()
            }
        }
    }

    func handleImageDataRequest(with message: WKScriptMessage) {
        guard let imageString = message.body as? String,
              let decodedData = Data(base64Encoded: imageString),
              let image = UIImage(data: decodedData) else {
            AppKitLogger.e("[App] Could not decode base64 string")
            jsonRpcInterceptor?.send(error: .badRequest)
            return
        }

        AppKit.shared.notifyImageData(with: image)
    }

    func handleApplePayAvailibilityCheck(with message: WKScriptMessage) {
        guard let body = message.body as? String else {
            jsonRpcInterceptor?.send(error: .badRequest)
            return
        }

        // Apple Pay Web is using a slightly different naming for their PKPaymentNetworks,
        // hence why we need to uppercase the first letter
        let networks: [PKPaymentNetwork] = body.split(separator: ",").compactMap { PKPaymentNetwork(String($0).firstUppercased) }
        let result = PKPaymentAuthorizationController.canMakePayments(usingNetworks: networks)

        jsonRpcInterceptor?.respond(result: result ? "true" : "false")
    }

    func handleApplePayPaymentRequest(with message: WKScriptMessage) {
        guard let body = message.body as? String else {
            jsonRpcInterceptor?.send(error: .badRequest)
            return
        }

        do {
            let request = try JSONDecoder().decode(AppKit.ApplePayRequest.self, from: Data(body.utf8))

            AppKit.shared.notifyApplePayData(with: request) { [weak self] response in
                self?.jsonRpcInterceptor?.respond(result: response)
            }
        } catch {
            jsonRpcInterceptor?.send(error: ["error": "\(error.localizedDescription)"])
        }
    }

    func handleLog(with message: WKScriptMessage) {
        guard let log = message.body as? String else { return }
        AppKitLogger.pwa(log)
    }
}

// MARK: - Location verification
extension App {
    func handleVerifyLocationRequest(with message: WKScriptMessage) {
        guard let body = message.body as? String else {
            jsonRpcInterceptor?.send(error: .badRequest)
            return
        }

        var verifyLocationMessageData: [String: AnyHashable]?

        do {
            verifyLocationMessageData = try JSONSerialization.jsonObject(with: Data(body.utf8), options: []) as? [String: AnyHashable]
        } catch {
            jsonRpcInterceptor?.send(error: ["error": "\(error.localizedDescription)"])
            return
        }

        guard let lat = verifyLocationMessageData?[MessageHandlerParam.lat.rawValue] as? Double,
              let lon = verifyLocationMessageData?[MessageHandlerParam.lon.rawValue] as? Double,
              let threshold = verifyLocationMessageData?[MessageHandlerParam.threshold.rawValue] as? Double else {
            jsonRpcInterceptor?.send(error: .badRequest)
            return
        }

        let locationToVerify = CLLocation(latitude: lat, longitude: lon)
        let currentAuthStatus = CLLocationManager.authorizationStatus()

        guard !(currentAuthStatus == .denied || currentAuthStatus == .notDetermined) else {
            passVerificationToClient(locationToVerify: locationToVerify, threshold: threshold)
            return
        }

        oneTimeLocationProvider.requestLocation { [weak self] userLocation in
            guard let userLocation = userLocation else {
                self?.passVerificationToClient(locationToVerify: locationToVerify, threshold: threshold)
                return
            }

            self?.verifyLocation(userLocation: userLocation, locationToVerify: locationToVerify, distanceThreshold: threshold)
        }
    }

    private func passVerificationToClient(locationToVerify: CLLocation, threshold: Double) {
        AppKit.shared.notifyDidRequestLocationVerfication(location: locationToVerify, threshold: threshold) { [weak self] isInRange in
            self?.jsonRpcInterceptor?.respond(result: isInRange ? "true" : "false")
        }
    }

    private func verifyLocation(userLocation: CLLocation?, locationToVerify: CLLocation, distanceThreshold: Double) {
        var isInRange: Bool = false
        if let distance = userLocation?.distance(from: locationToVerify) {
            isInRange = distance <= distanceThreshold
        }
        jsonRpcInterceptor?.respond(result: isInRange ? "true" : "false")
    }
}
