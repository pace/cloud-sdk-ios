//
//  AppKit+Delegate.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import CoreLocation
import UIKit

public protocol AppKitDelegate: AnyObject {
    func didFail(with error: AppKit.AppError)
    func didReceiveAppDrawers(_ appDrawers: [AppKit.AppDrawer], _ appDatas: [AppKit.AppData])
    func didReceiveAppData(_ appData: [AppKit.AppData])
    func didEscapeForecourt(_ appDatas: [AppKit.AppData])

    func didEnterGeofence(with id: String)
    func didExitGeofence(with id: String)
    func didFailToMonitorRegion(_ region: CLRegion, error: Error)

    func tokenInvalid(reason: AppKit.InvalidTokenReason, oldToken: String?, completion: @escaping ((String) -> Void))
    func didReceiveImageData(_ image: UIImage)
    func didReceiveApplePayDataRequest(_ request: AppKit.ApplePayRequest, completion: @escaping (([String: Any]?) -> Void))

    func didRequestLocationVerification(location: CLLocation, threshold: Double, completion: @escaping ((Bool) -> Void))

    func setUserProperty(key: String, value: String, update: Bool)
    func logEvent(key: String, parameters: [String: Any])
    func getConfig(key: String, completion: @escaping ((Any?) -> Void))
}

public extension AppKitDelegate {
    func didReceiveAppData(_ appData: [AppKit.AppData]) {}
    func didEscapeForecourt(_ appDatas: [AppKit.AppData]) {}
    func didEnterGeofence(with id: String) {}
    func didExitGeofence(with id: String) {}
    func didFailToMonitorRegion(_ region: CLRegion, error: Error) {}
    func tokenInvalid(reason: AppKit.InvalidTokenReason, oldToken: String?, completion: @escaping ((String) -> Void)) {}
    func didReceiveImageData(_ image: UIImage) {}
    func didReceiveApplePayDataRequest(_ request: AppKit.ApplePayRequest, completion: @escaping (([String: Any]?) -> Void)) {}
    func didRequestLocationVerification(location: CLLocation, threshold: Double, completion: @escaping ((Bool) -> Void)) {}
    func setUserProperty(key: String, value: String, update: Bool) {}
    func logEvent(key: String, parameters: [String: Any]) {}
    func getConfig(key: String, completion: @escaping ((Any?) -> Void)) {}
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

    func notifyInvalidToken(reason: AppKit.InvalidTokenReason, oldToken: String?, callback: @escaping ((String) -> Void)) {
        notifyClient { [weak self] in
            self?.delegate?.tokenInvalid(reason: reason, oldToken: oldToken, completion: callback)
        }
    }

    func notifyImageData(with image: UIImage) {
        notifyClient { [weak self] in
            self?.delegate?.didReceiveImageData(image)
        }
    }

    func notifyApplePayData(with request: ApplePayRequest, callback: @escaping (([String: Any]?) -> Void)) {
        notifyClient { [weak self] in
            self?.delegate?.didReceiveApplePayDataRequest(request, completion: callback)
        }
    }

    func notifyDidRequestLocationVerfication(location: CLLocation, threshold: Double, callback: @escaping ((Bool) -> Void)) {
        notifyClient { [weak self] in
            self?.delegate?.didRequestLocationVerification(location: location, threshold: threshold, completion: callback)
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

    private func notifyClient(_ notification: (() -> Void)?) {
        DispatchQueue.main.async {
            notification?()
        }
    }
}
