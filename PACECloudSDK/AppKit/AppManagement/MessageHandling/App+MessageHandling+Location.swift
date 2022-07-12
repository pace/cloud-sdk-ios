//
//  App+MessageHandling+Location.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import CoreLocation
import Foundation

// MARK: - Verify location
extension App {
    func handleVerifyLocation(with request: API.Communication.VerifyLocationRequest, completion: @escaping (API.Communication.VerifyLocationResult) -> Void) {
        let locationToVerify = CLLocation(latitude: request.lat, longitude: request.lon)
        let currentAuthStatus = CLLocationManager.authorizationStatus()

        guard !(currentAuthStatus == .denied || currentAuthStatus == .notDetermined) else {
            passVerificationToClient(locationToVerify: locationToVerify,
                                     threshold: request.threshold,
                                     completion: completion)
            return
        }

        oneTimeLocationProvider.requestLocation(useLastKnownLocationIfViable: true) { [weak self] userLocation in
            guard let userLocation = userLocation else {
                self?.passVerificationToClient(locationToVerify: locationToVerify,
                                               threshold: request.threshold,
                                               completion: completion)
                return
            }

            let distance = userLocation.distance(from: locationToVerify)
            let isInRange = distance <= request.threshold
            self?.respondToVerifyLocation(isInRange: isInRange, accuracy: userLocation.horizontalAccuracy, completion: completion)
        }
    }

    private func passVerificationToClient(locationToVerify: CLLocation, threshold: Double, completion: @escaping (API.Communication.VerifyLocationResult) -> Void) {
        AppKit.shared.notifyDidRequestLocationVerfication(location: locationToVerify, threshold: threshold) { [weak self] isInRange in
            self?.respondToVerifyLocation(isInRange: isInRange, accuracy: 0, completion: completion)
        }
    }

    private func respondToVerifyLocation(isInRange: Bool, accuracy: CLLocationAccuracy?, completion: @escaping (API.Communication.VerifyLocationResult) -> Void) {
        completion(.init(.init(response: .init(verified: isInRange, accuracy: accuracy))))
    }
}

// MARK: - Get location
extension App {
    func handleGetLocation(completion: @escaping (API.Communication.GetLocationResult) -> Void) {
        oneTimeLocationProvider.requestLocation(useLastKnownLocationIfViable: true) { [weak self] userLocation in
            guard let userLocation = userLocation else {
                self?.passGetLocationToClient(completion: completion)
                return
            }
            self?.respondToGetLocation(userLocation: userLocation, completion: completion)
        }
    }

    private func passGetLocationToClient(completion: @escaping (API.Communication.GetLocationResult) -> Void) {
        AppKit.shared.notifyCurrentLocation { [weak self] userLocation in
            self?.respondToGetLocation(userLocation: userLocation, completion: completion)
        }
    }

    private func respondToGetLocation(userLocation: CLLocation?, completion: @escaping (API.Communication.GetLocationResult) -> Void) {
        if let location = userLocation {
            let coordinates = location.coordinate
            completion(.init(.init(response: .init(lat: coordinates.latitude, lon: coordinates.longitude, accuracy: location.horizontalAccuracy, bearing: location.course))))
        } else {
            completion(.init(.init(statusCode: .notFound, response: .init(message: "Couldn't retrieve the user's location."))))
        }
    }
}
