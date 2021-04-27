//
//  App+MessageHandling.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import CoreLocation
import Foundation
import PassKit

// MARK: - Message handling
extension App {
    func handleCloseAction(with request: AppKit.EmptyRequestData) {
        messageInterceptor?.respond(id: request.id, statusCode: HttpStatusCode.okNoContent)

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

    func handleDisableAction(with request: AppKit.AppRequestData<AppKit.DisableAction>, requestUrl: URL?) {
        guard let host = requestUrl?.host else {
            messageInterceptor?.send(id: request.id, error: .badRequest)
            return
        }

        let untilTime = request.message.until

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
        messageInterceptor?.respond(id: request.id, statusCode: .ok)
    }

    func handleOpenURLInNewTabAction(with request: AppKit.AppRequestData<AppKit.OpenUrlInNewTabData>, requestUrl: URL?) {
        guard let sourceUrl = requestUrl else {
            messageInterceptor?.send(id: request.id, error: .badRequest)
            return
        }

        guard let appActionsDelegate = appActionsDelegate else {
            messageInterceptor?.respond(id: request.id, statusCode: HttpStatusCode.internalError)

            return
        }

        guard let cancelUrl = URL(string: request.message.cancelUrl) else {
            messageInterceptor?.send(id: request.id, error: .badRequest)
            AppKit.shared.notifyDidFail(with: .badRequest)
            load(URLRequest(url: sourceUrl))
            return
        }

        guard let customScheme = Bundle.main.clientRedirectScheme, let customUrl = URL(string: "\(customScheme)://") else {
            AppKit.shared.notifyDidFail(with: .customURLSchemeNotSet)
            messageInterceptor?.respond(id: request.id, statusCode: HttpStatusCode.internalError)

            load(URLRequest(url: cancelUrl))

            return
        }

        if UIApplication.shared.canOpenURL(customUrl) {
            appActionsDelegate.appRequestedNewTab(for: request.message.url, cancelUrl: cancelUrl.absoluteString)
            messageInterceptor?.respond(id: request.id, statusCode: HttpStatusCode.okNoContent)
        } else {
            messageInterceptor?.respond(id: request.id, statusCode: HttpStatusCode.methodNotAllowed)

            AppKit.shared.notifyDidFail(with: .customURLSchemeNotSet)

            load(URLRequest(url: cancelUrl))
        }
    }

    func handleInvalidTokenRequest(with request: AppKit.AppRequestData<AppKit.InvalidTokenData>, completion: @escaping () -> Void) {
        guard PACECloudSDK.shared.authenticationMode == .native else { return }

        let requestReason = request.message.reason

        let reason = AppKit.InvalidTokenReason(rawValue: requestReason) ?? .other
        let oldToken = request.message.oldToken

        AppKit.shared.notifyInvalidToken(reason: reason, oldToken: oldToken) { [weak self] token in
            PACECloudSDK.shared.currentAccessToken = token
            self?.messageInterceptor?.respond(id: request.id, message: token)
            completion()
        }
    }

    func handleImageDataRequest(with request: AppKit.AppRequestData<String>) {
        guard let decodedData = Data(base64Encoded: request.message),
              let image = UIImage(data: decodedData) else {
            AppKitLogger.e("[App] Could not decode base64 string")
            messageInterceptor?.send(id: request.id, error: .badRequest)
            return
        }

        AppKit.shared.notifyImageData(with: image)
    }

    func handleApplePayAvailibilityCheck(with request: AppKit.AppRequestData<String>) {
        // Apple Pay Web is using a slightly different naming for their PKPaymentNetworks,
        // hence why we need to uppercase the first letter
        let networks: [PKPaymentNetwork] = request.message.split(separator: ",").compactMap { PKPaymentNetwork(String($0).firstUppercased) }
        let result = PKPaymentAuthorizationController.canMakePayments(usingNetworks: networks)

        messageInterceptor?.respond(id: request.id, message: result ? true : false)
    }

    func handleApplePayPaymentRequest(with request: AppKit.AppRequestData<AppKit.ApplePayRequest>, completion: @escaping () -> Void) {
        AppKit.shared.notifyApplePayData(with: request.message) { [weak self] response in
            guard let response = response else {
                self?.messageInterceptor?.send(id: request.id, error: .internalError)
                completion()
                return
            }

            self?.messageInterceptor?.respond(id: request.id, message: response)
            completion()
        }
    }

    func handleLog(with message: String) {
        AppKitLogger.pwa(message)
    }

    func handleBack(with request: AppKit.EmptyRequestData) {
        if backForwardList.backItem == nil {
            handleCloseAction(with: request)
        } else {
            messageInterceptor?.respond(id: request.id, statusCode: HttpStatusCode.okNoContent)
            goBack()
        }
    }

    func handleRedirectScheme(with request: AppKit.EmptyRequestData) {
        guard let customScheme = Bundle.main.clientRedirectScheme else {
            messageInterceptor?.send(id: request.id, error: .notFound)
            AppKit.shared.notifyDidFail(with: .customURLSchemeNotSet)
            return
        }

        messageInterceptor?.respond(id: request.id, message: [MessageHandlerParam.link.rawValue: customScheme])
    }

    func handleSetUserProperty(with request: AppKit.AppRequestData<AppKit.SetUserPropertyData>) {
        let key = request.message.key
        let value = request.message.value
        let update = request.message.update ?? false
        AppKit.shared.notifySetUserProperty(key: key, value: value, update: update)
        messageInterceptor?.respond(id: request.id, statusCode: .okNoContent)
    }

    func handleLogEvent(with request: AppKit.AppRequestData<AppKit.LogEventData>) {
        let key = request.message.key
        let parameters: [String: Any] = request.message.parameters.reduce(into: [:], { $0[$1.key] = $1.value.value })
        AppKit.shared.notifyLogEvent(key: key, parameters: parameters)
        messageInterceptor?.respond(id: request.id, statusCode: .okNoContent)
    }

    func handleGetConfig(with request: AppKit.AppRequestData<AppKit.GetConfigData>, completion: @escaping () -> Void) {
        let key = request.message.key
        AppKit.shared.notifyGetConfig(key: key) { [weak self] value in
            guard let value = value else {
                self?.messageInterceptor?.send(id: request.id, error: .notFound)
                completion()
                return
            }
            self?.messageInterceptor?.respond(id: request.id, message: [MessageHandlerParam.value.rawValue: "\(value)"])
            completion()
        }
    }
}

// MARK: - Location verification
extension App {
    func handleVerifyLocationRequest(with request: AppKit.AppRequestData<AppKit.VerifyLocationData>, completion: @escaping () -> Void) {
        let locationToVerify = CLLocation(latitude: request.message.lat, longitude: request.message.lon)
        let currentAuthStatus = CLLocationManager.authorizationStatus()

        guard !(currentAuthStatus == .denied || currentAuthStatus == .notDetermined) else {
            passVerificationToClient(id: request.id,
                                     locationToVerify: locationToVerify,
                                     threshold: request.message.threshold,
                                     completion: completion)
            return
        }

        oneTimeLocationProvider.requestLocation { [weak self] userLocation in
            guard let userLocation = userLocation else {
                self?.passVerificationToClient(id: request.id,
                                               locationToVerify: locationToVerify,
                                               threshold: request.message.threshold,
                                               completion: completion)
                return
            }

            self?.verifyLocation(id: request.id, userLocation: userLocation, locationToVerify: locationToVerify, distanceThreshold: request.message.threshold)
            completion()
        }
    }

    private func passVerificationToClient(id: String, locationToVerify: CLLocation, threshold: Double, completion: @escaping () -> Void) {
        AppKit.shared.notifyDidRequestLocationVerfication(location: locationToVerify, threshold: threshold) { [weak self] isInRange in
            self?.messageInterceptor?.respond(id: id, message: isInRange ? "true" : "false")
            completion()
        }
    }

    private func verifyLocation(id: String, userLocation: CLLocation?, locationToVerify: CLLocation, distanceThreshold: Double) {
        var isInRange: Bool = false
        if let distance = userLocation?.distance(from: locationToVerify) {
            isInRange = distance <= distanceThreshold
        }
        messageInterceptor?.respond(id: id, message: isInRange ? "true" : "false")
    }
}