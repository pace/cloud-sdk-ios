//
//  DrawerViewModelImplementation.swift
//  PACECloudSDKExample
//
//  Created by PACE Telematics GmbH.
//

import CoreLocation
import Foundation
import PACECloudSDK
import SwiftUI

class DrawerViewModelImplementation: DrawerViewModel {
    @Published private(set) var drawers: [AppKit.AppDrawer] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var didFailDrawers: Bool = false

    private let locationManager: LocationManager
    private var previousLocation: CLLocation?

    init() {
        locationManager = LocationManager()
        locationManager.delegate = self
        AppControl.shared.delegate = self
    }

    func requestAppDrawers() {
        didFailDrawers = false
        isLoading = true
        AppControl.shared.requestLocalApps()
    }
}

extension DrawerViewModelImplementation: LocationManagerDelegate {
    func didUpdateLocations(locations: [CLLocation]) {
        guard let location = locations.last,
              previousLocation == nil || location.distance(from: previousLocation!) > 15 else { return } // swiftlint:disable:this force_unwrapping

        requestAppDrawers()
        previousLocation = location
    }

    func didFail(with error: Error) {
        isLoading = false
        didFailDrawers = true
        ExampleLogger.e("\(error)")
    }
}

extension DrawerViewModelImplementation: AppControlDelegate {
    func didReceiveDrawers(_ drawers: [AppKit.AppDrawer]) {
        isLoading = false
        self.drawers = drawers
    }

    func didFail() {
        isLoading = false
        didFailDrawers = true
    }
}
