//
//  App+MessageHandling+Location.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import CoreLocation
import Foundation

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
            self?.respondToVerifyLocation(isInRange: isInRange, accuracy: nil, completion: completion)
        }
    }

    private func respondToVerifyLocation(isInRange: Bool, accuracy: CLLocationAccuracy?, completion: @escaping (API.Communication.VerifyLocationResult) -> Void) {
        completion(.init(.init(response: .init(verified: isInRange, accuracy: accuracy))))
    }
}
