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

    private let manager: CLLocationManager = .init()
    private var locationUpdateHandler: ((CLLocation?) -> Void)?

    override init() {
        super.init()

        manager.delegate = self
    }

    func requestLocation(locationUpdateHandler: ((CLLocation?) -> Void)? = nil) {
        self.locationUpdateHandler = locationUpdateHandler
        manager.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        delegate?.didFinishLocationRequest(with: location)
        locationUpdateHandler?(location)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        AppKitLogger.e("[OneTimeLocationProvider] Requesting location failed with error \(error)")
        delegate?.didFinishLocationRequest(with: nil)
        locationUpdateHandler?(nil)
    }
}
