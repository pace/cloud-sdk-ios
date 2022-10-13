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
    private let maximalLocationAge: TimeInterval = 30
    private var locationUpdateHandler: [((CLLocation?) -> Void)] = .init()
    private lazy var workQueue: DispatchQueue = .init(label: "location-provider-queue")

    override init() {
        super.init()

        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }

    func requestLocation(useLastKnownLocationIfViable: Bool = false, completion: ((CLLocation?) -> Void)? = nil) {
        workQueue.async { [weak self] in
            if let handler = completion {
                self?.locationUpdateHandler.append(handler)
            }
        }

        guard useLastKnownLocationIfViable,
              let location = lastKnownLocationIfViable() else {
            manager.startUpdatingLocation()
            return
        }

        notifyReceivers(location)
        SDKLogger.v("[OneTimeLocationProvider] Using the last known location as it's still viable.")
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()

        let location = locations.first(where: { 0...lowAccuracy ~= $0.horizontalAccuracy })
        notifyReceivers(location)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        SDKLogger.e("[OneTimeLocationProvider] Requesting location failed with error \(error)")

        manager.stopUpdatingLocation()
        notifyReceivers(nil)
    }

    private func lastKnownLocationIfViable() -> CLLocation? {
        guard let lastKnownLocation = manager.location,
              0...lowAccuracy ~= lastKnownLocation.horizontalAccuracy,
              0...maximalLocationAge ~= abs(lastKnownLocation.timestamp.timeIntervalSinceNow) else { return nil }
        return lastKnownLocation
    }

    private func notifyReceivers(_ location: CLLocation?) {
        delegate?.didFinishLocationRequest(with: location)

        workQueue.async { [weak self] in
            self?.locationUpdateHandler.forEach { $0(location) }
            self?.locationUpdateHandler.removeAll()
        }
    }
}
