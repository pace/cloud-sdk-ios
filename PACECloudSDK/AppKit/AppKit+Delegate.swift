//
//  AppKit+Delegate.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import CoreLocation
import PassKit
import UIKit

public protocol AppKitDelegate: AnyObject {
    func didFail(with error: AppKit.AppError)
    func didReceiveAppDrawers(_ appDrawers: [AppKit.AppDrawer], _ appDatas: [AppKit.AppData])
    func didReceiveAppData(_ appData: [AppKit.AppData])
    func didEscapeForecourt(_ appDatas: [AppKit.AppData])

    func didEnterGeofence(with id: String)
    func didExitGeofence(with id: String)
    func didFailToMonitorRegion(_ region: CLRegion, error: Error)

    func getAccessToken(reason: AppKit.GetAccessTokenReason, oldToken: String?, completion: @escaping ((API.Communication.GetAccessTokenResponse) -> Void))
    func logout(completion: @escaping ((AppKit.LogoutResponse) -> Void))
    func didReceiveImageData(_ image: UIImage)
    func didReceiveText(title: String, text: String)

    func paymentRequestMerchantIdentifier(completion: @escaping (String) -> Void)
    func didCreateApplePayPaymentRequest(_ request: PKPaymentRequest, completion: @escaping (API.Communication.ApplePayRequestResponse?) -> Void)

    func didRequestLocationVerification(location: CLLocation, threshold: Double, completion: @escaping ((Bool) -> Void))
    func currentLocation(completion: @escaping (CLLocation?) -> Void)

    func setUserProperty(key: String, value: String, update: Bool)
    func logEvent(key: String, parameters: [String: Any])
    func getConfig(key: String, completion: @escaping ((Any?) -> Void))
    func isAppRedirectAllowed(app: String, isAllowed: @escaping ((Bool) -> Void))
    func isRemoteConfigAvailable(isAvailable: @escaping ((Bool) -> Void))
}

public extension AppKitDelegate {
    func didReceiveAppData(_ appData: [AppKit.AppData]) {}
    func didEscapeForecourt(_ appDatas: [AppKit.AppData]) {}
    func didEnterGeofence(with id: String) {}
    func didExitGeofence(with id: String) {}
    func didFailToMonitorRegion(_ region: CLRegion, error: Error) {}
    func getAccessToken(reason: AppKit.GetAccessTokenReason, oldToken: String?, completion: @escaping ((API.Communication.GetAccessTokenResponse) -> Void)) {}
    func didReceiveImageData(_ image: UIImage) {
        let item = ShareObject(shareData: image, customTitle: Bundle.main.bundleName)
        let av = UIActivityViewController(activityItems: [item], applicationActivities: nil)
        UIApplication.shared.windows.last?.rootViewController?.present(av, animated: true, completion: nil)
    }
    func paymentRequestMerchantIdentifier(completion: @escaping (String) -> Void) { completion("") }
    func didCreateApplePayPaymentRequest(_ request: PKPaymentRequest, completion: @escaping (API.Communication.ApplePayRequestResponse?) -> Void) { completion(nil) }
    func didRequestLocationVerification(location: CLLocation, threshold: Double, completion: @escaping ((Bool) -> Void)) { completion(false) }
    func currentLocation(completion: @escaping (CLLocation?) -> Void) { completion(nil) }
    func setUserProperty(key: String, value: String, update: Bool) {}
    func logEvent(key: String, parameters: [String: Any]) {}
    func getConfig(key: String, completion: @escaping ((Any?) -> Void)) { completion(nil) }
    func isAppRedirectAllowed(app: String, isAllowed: @escaping ((Bool) -> Void)) { isAllowed(true) }
    func isRemoteConfigAvailable(isAvailable: @escaping ((Bool) -> Void)) { isAvailable(false) }
    func didReceiveText(title: String, text: String) {
        let item = ShareObject(shareData: text, customTitle: title)
        let av = UIActivityViewController(activityItems: [item], applicationActivities: nil)
        UIApplication.shared.windows.last?.rootViewController?.present(av, animated: true, completion: nil)
    }
}

extension AppKit {
    func notifyDidFail(with error: AppError) {
        notifyClient { [weak self] in
            self?.delegate?.didFail(with: error)
        }
    }

    func notifyDidReceiveAppDrawerContainer(_ appDrawers: [AppDrawer], _ appDatas: [AppData]) {
        notifyClient { [weak self] in
            self?.delegate?.didReceiveAppDrawers(appDrawers, appDatas)
            self?.delegate?.didReceiveAppData(appDatas)
        }
    }

    func notifyDidEscapeForecourt(_ appDatas: [AppData]) {
        notifyClient { [weak self] in
            self?.delegate?.didEscapeForecourt(appDatas)
        }
    }

    func notifyDidEnterGeofence(with id: String) {
        notifyClient { [weak self] in
            self?.delegate?.didEnterGeofence(with: id)
        }
    }

    func notifyDidExitGeofence(with id: String) {
        notifyClient { [weak self] in
            self?.delegate?.didExitGeofence(with: id)
        }
    }

    func notifyDidFailToMonitorRegion(_ region: CLRegion, error: Error) {
        notifyClient { [weak self] in
            self?.delegate?.didFailToMonitorRegion(region, error: error)
        }
    }

    func notifyGetAccessToken(reason: AppKit.GetAccessTokenReason, oldToken: String?, callback: @escaping ((API.Communication.GetAccessTokenResponse) -> Void)) {
        notifyClient { [weak self] in
            self?.delegate?.getAccessToken(reason: reason, oldToken: oldToken, completion: callback)
        }
    }

    func notifyLogout(callback: @escaping ((LogoutResponse) -> Void)) {
        notifyClient { [weak self] in
            self?.delegate?.logout(completion: callback)
        }
    }

    func notifyImageData(with image: UIImage) {
        notifyClient { [weak self] in
            self?.delegate?.didReceiveImageData(image)
        }
    }

    func notifyMerchantIdentifier(callback: @escaping (String) -> Void) {
        notifyClient { [weak self] in
            self?.delegate?.paymentRequestMerchantIdentifier(completion: callback)
        }
    }

    func notifyApplePayRequest(with request: PKPaymentRequest, callback: @escaping (API.Communication.ApplePayRequestResponse?) -> Void) {
        notifyClient { [weak self] in
            self?.delegate?.didCreateApplePayPaymentRequest(request, completion: callback)
        }
    }

    func notifyDidRequestLocationVerfication(location: CLLocation, threshold: Double, callback: @escaping ((Bool) -> Void)) {
        notifyClient { [weak self] in
            self?.delegate?.didRequestLocationVerification(location: location, threshold: threshold, completion: callback)
        }
    }

    func notifyCurrentLocation(callback: @escaping (CLLocation?) -> Void) {
        notifyClient { [weak self] in
            self?.delegate?.currentLocation(completion: callback)
        }
    }

    func notifySetUserProperty(key: String, value: String, update: Bool) {
        notifyClient { [weak self] in
            self?.delegate?.setUserProperty(key: key, value: value, update: update)
        }
    }

    func notifyLogEvent(key: String, parameters: [String: Any]) {
        notifyClient { [weak self] in
            self?.delegate?.logEvent(key: key, parameters: parameters)
        }
    }

    func notifyGetConfig(key: String, completion: @escaping ((Any?) -> Void)) {
        notifyClient { [weak self] in
            self?.delegate?.getConfig(key: key, completion: completion)
        }
    }

    func notifyIsAppRedirectAllowed(app: String, isAllowed: @escaping ((Bool) -> Void)) {
        notifyClient { [weak self] in
            self?.delegate?.isAppRedirectAllowed(app: app, isAllowed: isAllowed)
        }
    }

    func notifyIsRemoteConfigAvailable(isAvailable: @escaping ((Bool) -> Void)) {
        notifyClient { [weak self] in
            self?.delegate?.isRemoteConfigAvailable(isAvailable: isAvailable)
        }
    }

    func notifyDidReceiveText(title: String, text: String) {
        notifyClient { [weak self] in
            self?.delegate?.didReceiveText(title: title, text: text)
        }
    }

    private func notifyClient(_ notification: (() -> Void)?) {
        DispatchQueue.main.async {
            notification?()
        }
    }
}
