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
    var interceptor: AppWebViewInterceptor? { get }
    var jsonRpcInterceptor: AppWebViewJsonRpcInterceptor? { get }
    var appActionsDelegate: AppActionsDelegate? { get set }
    var appSecureCommunicationDelegate: AppSecureCommunicationDelegate? { get set }
    var paymentDelegate: AppPaymentDelegate? { get set }
    var reopenData: ReopenData? { get set }
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

    func loadUrlForVerifiedHost(urlString: String, host: String) {
        DispatchQueue.main.async {
            guard self.url?.host == host else {
                AppKitLogger.e("[App] Can't load URL, because host mismatch.")
                AppKit.shared.notifyDidFail(with: .failedRetrievingUrl)

                return
            }

            self.loadUrl(urlString: urlString)
        }
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

    func handleCloseAction(query: String?) {
        reopenData = ReopenData(from: query ?? "")

        guard let appActionsDelegate = appActionsDelegate else {
            // WebView directly added to client's view
            self.removeFromSuperview()
            return
        }

        // WebView opened in view controller
        appActionsDelegate.appRequestedCloseAction() // Close AppViewController if available
    }

    func handlePaymentAction(query: String) {
        guard let paymentConfirmationData = PaymentConfirmationData(from: query) else {
            AppKit.shared.notifyDidFail(with: .paymentError)
            return
        }

        self.paymentDelegate?.showPaymentConfirmation(with: paymentConfirmationData)
    }

    func provideReopenData() -> ReopenData? {
        return reopenData
    }

    func handleDisableAction(query: String, host: String) {
        let queryItems = URLDecomposer.decomposeQuery(query)

        guard let untilString = queryItems[URLParam.until.rawValue], let untilTime = Double(untilString) else { return }

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

    func handleOpenURLInNewTabAction(query: String, sourceUrl: URL) {
        let queryItems = URLDecomposer.decomposeQuery(query)

        guard let appActionsDelegate = appActionsDelegate else { return }

        guard let url: String = queryItems["url"], let cancelUrlString: String = queryItems["cancel_url"], let cancelUrl = URL(string: cancelUrlString) else {
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
}

// MARK: - Rpc
extension App {
    func handleInvalidTokenRequest() {
        guard PACECloudSDK.shared.authenticationMode == .native else { return }

        if let token = PACECloudSDK.shared.initialAccessToken, TokenValidator.isTokenValid(token) {
            jsonRpcInterceptor?.respond(result: token)
        } else {
            sendInvalidTokenCallback()
        }

        PACECloudSDK.shared.initialAccessToken = nil
    }

    func handleImageDataRequest(with message: WKScriptMessage) {
        guard let imageString = message.body as? String,
              let decodedData = Data(base64Encoded: imageString),
              let image = UIImage(data: decodedData) else {
            AppKitLogger.e("[App] Could not decode base64 string")
            return
        }

        AppKit.shared.notifyImageData(with: image)
    }

    private func sendInvalidTokenCallback() {
        AppKit.shared.notifyInvalidToken { [weak self] token in
            if TokenValidator.isTokenValid(token) {
                PACECloudSDK.shared.currentAccessToken = token
                self?.jsonRpcInterceptor?.respond(result: token)
            } else {
                self?.sendInvalidTokenCallback()
            }
        }
    }

    func handleApplePayAvailibilityCheck(with message: WKScriptMessage) {
        guard let message = message.body as? String else {
            jsonRpcInterceptor?.send(error: ["error": "Bad request"])
            return
        }

        // Apple Pay Web is using a slightly different naming for their PKPaymentNetworks,
        // hence why we need to uppercase the first letter
        let networks: [PKPaymentNetwork] = message.split(separator: ",").compactMap { PKPaymentNetwork(String($0).firstUppercased) }
        let result = PKPaymentAuthorizationController.canMakePayments(usingNetworks: networks)

        jsonRpcInterceptor?.respond(result: result ? "true" : "false")
    }

    func handleApplePayPaymentRequest(with message: WKScriptMessage) {
        guard let message = message.body as? String else {
            jsonRpcInterceptor?.send(error: ["error": "Bad request"])
            return
        }

        do {
            let request = try JSONDecoder().decode(AppKit.ApplePayRequest.self, from: Data(message.utf8))

            AppKit.shared.notifyApplePayData(with: request) { [weak self] response in
                self?.jsonRpcInterceptor?.respond(result: response)
            }
        } catch {
            jsonRpcInterceptor?.send(error: ["error": "error.localizedDescription"])
        }
    }
}

// MARK: - Location verification
extension App {
    func handleVerifyLocationRequest(with message: WKScriptMessage) {
        guard let message = message.body as? [String: String],
              let latString = message["lat"],
              let lonString = message["lon"],
              let thresholdString = message["threshold"],
              let lat = Double(latString),
              let lon = Double(lonString),
              let threshold = Double(thresholdString)
        else {
            jsonRpcInterceptor?.send(error: ["error": "Bad request"])
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
