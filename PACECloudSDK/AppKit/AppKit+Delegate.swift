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
    func didEscapeForecourt(_ appDatas: [AppKit.AppData])

    func didEnterGeofence(with id: String)
    func didExitGeofence(with id: String)
    func didFailToMonitorRegion(_ region: CLRegion, error: Error)

    func tokenInvalid(completion: @escaping ((String) -> Void))

    func didReceiveImageData(_ image: UIImage)
}

public extension AppKitDelegate {
    func didEscapeForecourt(_ appDatas: [AppKit.AppData]) {}
    func didEnterGeofence(with id: String) {}
    func didExitGeofence(with id: String) {}
    func didFailToMonitorRegion(_ region: CLRegion, error: Error) {}
    func tokenInvalid(completion: @escaping ((String) -> Void)) {}
    func didReceiveImageData(_ image: UIImage) {}
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

    func notifyInvalidToken(callback: @escaping ((String) -> Void)) {
        notifyClient { [weak self] in
            self?.delegate?.tokenInvalid(completion: callback)
        }
    }

    func notifyImageData(with image: UIImage) {
        notifyClient { [weak self] in
            self?.delegate?.didReceiveImageData(image)
        }
    }

    private func notifyClient(_ notification: (() -> Void)?) {
        DispatchQueue.main.async {
            notification?()
        }
    }
}
