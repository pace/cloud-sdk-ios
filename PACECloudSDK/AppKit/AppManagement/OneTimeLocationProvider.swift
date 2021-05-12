//
//  OneTimeLocationProvider.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import CoreLocation
import Foundation

protocol OneTimeLocationProviderDelegate: AnyObject {
    func didFinishLocationRequest(with location: CLLocation?)
}

class OneTimeLocationProvider: NSObject, CLLocationManagerDelegate {
    weak var delegate: OneTimeLocationProviderDelegate?

    var lowAccuracy: CLLocationDistance = Constants.Configuration.defaultAllowedLowAccuracy

    private let manager: CLLocationManager = .init()
    private var locationUpdateHandler: [((CLLocation?) -> Void)] = .init()
    private lazy var workQueue: DispatchQueue = .init(label: "location-provider-queue")

    override init() {
        super.init()

        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }

    func requestLocation(completion: ((CLLocation?) -> Void)? = nil) {
        workQueue.async { [weak self] in
            if let handler = completion {
                self?.locationUpdateHandler.append(handler)
            }
        }

        manager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()

        let location = locations.first(where: { 0...lowAccuracy ~= $0.horizontalAccuracy })
        delegate?.didFinishLocationRequest(with: location)

        notifyHandlers(location)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        AppKitLogger.e("[OneTimeLocationProvider] Requesting location failed with error \(error)")

        manager.stopUpdatingLocation()
        delegate?.didFinishLocationRequest(with: nil)

        notifyHandlers(nil)
    }

    private func notifyHandlers(_ location: CLLocation?) {
        workQueue.async { [weak self] in
            self?.locationUpdateHandler.forEach { $0(location) }
            self?.locationUpdateHandler.removeAll()
        }
    }
}
