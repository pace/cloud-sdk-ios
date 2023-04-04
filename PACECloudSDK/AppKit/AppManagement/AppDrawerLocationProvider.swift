//
//  AppDrawerLocationProvider.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import CoreLocation

protocol AppDrawerLocationProviderDelegate: AnyObject {
    func didReceiveLocation(_ location: CLLocation)
    func didFailWithError(_ error: Error)
}

struct LocationAccuracyThreshold {
    let timeout: TimeInterval
    let accuracy: CLLocationDistance
    var timeoutWorker: DispatchWorkItem?
}

class AppDrawerLocationProvider: NSObject {
    var thresholds = [LocationAccuracyThreshold]()

    var lowAccuracy: CLLocationDistance = Constants.Configuration.defaultAllowedLowAccuracy {
        didSet {
            updateLocationAccuracyThresholds()
        }
    }
    let midAccuracy: CLLocationDistance = 40
    let highAccuracy: CLLocationDistance = 20

    let maximalLocationAge: TimeInterval = 30

    var timeout: TimeInterval

    private var locationStartTime: Date = Date()

    private var currentLocation: CLLocation? {
        didSet {
            if let location = currentLocation {
                AppKitLogger.d("[Location Provider] Did receive accurate location: \(location)")

                delegate?.didReceiveLocation(location)
                savedLocations.removeAll()
                reset()
            }
        }
    }

    private var savedLocations: [CLLocation] = []

    private var locationFetchRunning = false

    weak var delegate: AppDrawerLocationProviderDelegate?

    lazy var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.delegate = self
        return locationManager
    }()

    init(timeout: TimeInterval = 30) {
        AppKitLogger.d("[AppDrawerLocationProvider] Initializing AppDrawerLocationProvider with timeout \(timeout)")
        self.timeout = timeout
        super.init()
        updateLocationAccuracyThresholds()
    }

    private func updateLocationAccuracyThresholds() {
        let segmentTime = timeout / 5

        thresholds = [
            LocationAccuracyThreshold(timeout: segmentTime * 1, accuracy: highAccuracy, timeoutWorker: nil),
            LocationAccuracyThreshold(timeout: segmentTime * 2, accuracy: midAccuracy, timeoutWorker: nil),
            LocationAccuracyThreshold(timeout: segmentTime * 3, accuracy: lowAccuracy, timeoutWorker: nil),
            LocationAccuracyThreshold(timeout: segmentTime * 4, accuracy: lowAccuracy, timeoutWorker: nil),
            LocationAccuracyThreshold(timeout: segmentTime * 5, accuracy: lowAccuracy, timeoutWorker: nil)
        ]
    }

    func startFetchingLocation() {
        guard !locationFetchRunning else {
            AppKitLogger.d("[AppDrawerLocationProvider] Fetching location requested but already running")
            return
        }

        guard !isLocationAccuracyReduced() else {
            self.delegate?.didFailWithError(CLError(CLError.Code.deferredAccuracyTooLow))
            AppKitLogger.w("[AppDrawerLocationProvider] Can't fetch location due to reduced location permission setting")
            return
        }

        AppKitLogger.d("[AppDrawerLocationProvider] Start fetching location")

        locationStartTime = Date()
        locationManager.startUpdatingLocation()
        locationFetchRunning = true

        for i in 0...thresholds.count - 1 {
            thresholds[i].timeoutWorker?.cancel()
            thresholds[i].timeoutWorker = DispatchWorkItem {
                AppKitLogger.d("[AppDrawerLocationProvider] Timeout for segment \(i) of \(self.thresholds.count - 1)")

                if i == self.thresholds.count - 1 {
                    self.currentLocation = self.filterLocations(self.savedLocations, basedOn: self.locationStartTime)

                    if self.currentLocation == nil {
                        self.reset()
                        self.delegate?.didFailWithError(CLError(CLError.Code.locationUnknown))
                    }
                } else {
                    // Re-Filter
                    self.currentLocation = self.filterLocations(self.savedLocations, basedOn: self.locationStartTime)
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(Int(thresholds[i].timeout)), execute: thresholds[i].timeoutWorker!) // swiftlint:disable:this force_unwrapping
        }
    }

    func filterLocations(_ locations: [CLLocation], basedOn startTime: Date) -> CLLocation? {
        let timePassed = abs(startTime.timeIntervalSinceNow)

        for threshold in thresholds where timePassed <= threshold.timeout {
            guard let location = locations.first(where: { 0...threshold.accuracy ~= $0.horizontalAccuracy }) else { continue }
            return location
        }

        return nil
    }

    private func isLocationAccuracyReduced() -> Bool {
        if #available(iOS 14.0, *) {
            return locationManager.accuracyAuthorization == .reducedAccuracy
        }
        return false
    }

    private func reset() {
        AppKitLogger.d("[AppDrawerLocationProvider] Reset")

        thresholds.forEach { $0.timeoutWorker?.cancel() }
        locationManager.stopUpdatingLocation()
        locationFetchRunning = false
    }
}

// MARK: - CLLocationManagerDelegate
extension AppDrawerLocationProvider: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status != .authorizedAlways && status != .authorizedWhenInUse {
            AppKit.shared.notifyDidFail(with: .locationNotAuthorized)
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        savedLocations.append(contentsOf: locations)
        savedLocations = savedLocations.sorted(by: { $0.timestamp > $1.timestamp }).filter { 0...maximalLocationAge ~= abs($0.timestamp.timeIntervalSinceNow) }

        AppKitLogger.d("[AppDrawerLocationProvider] Filtered locations count \(savedLocations.count)")

        currentLocation = filterLocations(savedLocations, basedOn: locationStartTime)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        guard let clError = error as? CLError else { return }

        switch clError.code {
        case .locationUnknown:
            // According to Apple docs:
            // If the location service is unable to retrieve a location right away,
            // it reports a CLError.Code.locationUnknown error and keeps trying.
            // In such a situation, you can simply ignore the error and wait for a new event.
            AppKitLogger.d("[AppDrawerLocationProvider] Location unknown")

        default:
            AppKitLogger.d("[AppDrawerLocationProvider] Location fetch failed with error: \(error)")

            thresholds.forEach { $0.timeoutWorker?.cancel() }
            delegate?.didFailWithError(clError)
            locationManager.stopUpdatingLocation()
        }
    }
}
