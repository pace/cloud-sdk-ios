//
//  POIKitDelegate.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import CoreLocation
import Foundation

public protocol POIKitDelegate: AnyObject {
    func didUpdateLocations(_ locations: [CLLocation])
    func didChangeLocationAuthorizationStatus(_ status: CLAuthorizationStatus)
    func didUpdateHeading(_ heading: CLHeading)
    func didFailLocationWithError(_ error: CLError, locationServiceEnabled: Bool)
    func locationPermissionDenied()
    func nonFatalErrorOccured(_ error: Error, _ shouldCrash: Bool)
}
