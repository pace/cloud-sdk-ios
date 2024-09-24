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

    func getAccessToken(reason: AppKit.GetAccessTokenReason, oldToken: String?, completion: @escaping ((API.Communication.GetAccessTokenResponse) -> Void))
    func logout(completion: @escaping ((AppKit.LogoutResponse) -> Void))
    func didReceiveImageData(_ image: UIImage)
    func didReceiveFileData(_ data: Data)
    func didReceiveText(title: String, text: String)

    func didRequestLocationVerification(location: CLLocation, threshold: Double, completion: @escaping ((Bool) -> Void))
    func currentLocation(completion: @escaping (CLLocation?) -> Void)

    func setUserProperty(key: String, value: String, update: Bool)
    func logEvent(key: String, parameters: [String: Any], context: [String: Any]?)
    func getConfig(key: String, completion: @escaping ((Any?) -> Void))
    func isAppRedirectAllowed(app: String, isAllowed: @escaping ((Bool) -> Void))
    func isRemoteConfigAvailable(isAvailable: @escaping ((Bool) -> Void))
    func startNavigation(_ request: API.Communication.StartNavigationRequest, completion: @escaping (Bool) -> Void)

    func getReceiptEmail(_ request: API.Communication.ReceiptEmailRequest, completion: @escaping (String?) -> Void)
    func getReceiptAttachments(_ request: API.Communication.ReceiptAttachmentsRequest, completion: @escaping ([String]?) -> Void)
}

public extension AppKitDelegate {
    func didFail(with error: AppKit.AppError) {}
    func didReceiveAppDrawers(_ appDrawers: [AppKit.AppDrawer], _ appDatas: [AppKit.AppData]) {}
    func didReceiveAppData(_ appData: [AppKit.AppData]) {}
    func didEscapeForecourt(_ appDatas: [AppKit.AppData]) {}
    func getAccessToken(reason: AppKit.GetAccessTokenReason, oldToken: String?, completion: @escaping ((API.Communication.GetAccessTokenResponse) -> Void)) {}
    func didRequestLocationVerification(location: CLLocation, threshold: Double, completion: @escaping ((Bool) -> Void)) { completion(false) }
    func currentLocation(completion: @escaping (CLLocation?) -> Void) { completion(nil) }
    func setUserProperty(key: String, value: String, update: Bool) {}
    func logEvent(key: String, parameters: [String: Any], context: [String: Any]?) {}
    func getConfig(key: String, completion: @escaping ((Any?) -> Void)) { completion(nil) }
    func isAppRedirectAllowed(app: String, isAllowed: @escaping ((Bool) -> Void)) { isAllowed(true) }
    func isRemoteConfigAvailable(isAvailable: @escaping ((Bool) -> Void)) { isAvailable(false) }
    func startNavigation(_ request: API.Communication.StartNavigationRequest, completion: @escaping (Bool) -> Void) { completion(false) }

    func getReceiptEmail(_ request: API.Communication.ReceiptEmailRequest, completion: @escaping (String?) -> Void) { completion(nil) }

    func getReceiptAttachments(_ request: API.Communication.ReceiptAttachmentsRequest, completion: @escaping ([String]?) -> Void) { completion(nil) }
}

public extension AppKitDelegate {
    func didReceiveImageData(_ image: UIImage) {
        let item = ShareObject(shareData: image, customTitle: Bundle.main.bundleName)
        shareItem(item)
    }
    
    func didReceiveFileData(_ data: Data) {
        let item = ShareObject(shareData: data, customTitle: Bundle.main.bundleName)
        shareItem(item)
    }

    func didReceiveText(title: String, text: String) {
        let item = ShareObject(shareData: text, customTitle: title)
        shareItem(item)
    }
}

private extension AppKitDelegate {
    func shareItem(_ item: ShareObject) {
        let av = UIActivityViewController(activityItems: [item], applicationActivities: nil)
        UIWindow.topMost?.rootViewController?.present(av, animated: true, completion: nil)
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

    func notifyShareFile(data: Data) {
        notifyClient { [weak self] in
            self?.delegate?.didReceiveFileData(data)
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

    func notifyLogEvent(key: String, parameters: [String: Any], context: [String: Any]?) {
        notifyClient { [weak self] in
            self?.delegate?.logEvent(key: key, parameters: parameters, context: context)
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

    func notifyStartNavigation(request: API.Communication.StartNavigationRequest, completion: @escaping (Bool) -> Void) {
        notifyClient { [weak self] in
            self?.delegate?.startNavigation(request, completion: completion)
        }
    }

    func notifyGetReceiptEmail(request: API.Communication.ReceiptEmailRequest, completion: @escaping (String?) -> Void) {
        notifyClient { [weak self] in
            self?.delegate?.getReceiptEmail(request, completion: completion)
        }
    }

    func notifyGetReceiptAttachments(request: API.Communication.ReceiptAttachmentsRequest, completion: @escaping ([String]?) -> Void) {
        notifyClient { [weak self] in
            self?.delegate?.getReceiptAttachments(request, completion: completion)
        }
    }

    private func notifyClient(_ notification: (() -> Void)?) {
        DispatchQueue.main.async {
            notification?()
        }
    }
}
