//
//  LocationManager.swift
//  PACECloudSDKExample
//
//  Created by PACE Telematics GmbH.
//

import CoreLocation
import Foundation
import SwiftUI

protocol LocationManagerDelegate: AnyObject {
    func didUpdateLocations(locations: [CLLocation])
    func didFail(with error: Error)
}

class LocationManager: NSObject {
    weak var delegate: LocationManagerDelegate?

    private let locationManager: CLLocationManager

    override init() {
        locationManager = CLLocationManager()

        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }

    deinit {
        locationManager.stopUpdatingLocation()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard manager.authorizationStatus == .authorizedAlways || manager.authorizationStatus == .authorizedWhenInUse else {
            ExampleLogger.i("[LocationManager] Wrong location authorization status: \(manager.authorizationStatus.rawValue)")
            return
        }
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        delegate?.didUpdateLocations(locations: locations)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        delegate?.didFail(with: error)
        ExampleLogger.e("[LocationManager] Did fail with error \(error)")
    }
}
