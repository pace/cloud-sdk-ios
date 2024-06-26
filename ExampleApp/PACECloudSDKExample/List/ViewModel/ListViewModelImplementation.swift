//
//  ListViewModelImplementation.swift
//  PACECloudSDKExample
//
//  Created by PACE Telematics GmbH.
//

import CoreLocation
import Foundation
import PACECloudSDK
import SwiftUI

class ListViewModelImplementation: ListViewModel {
    @Published private(set) var cofuStations: [ListGasStation] = []
    @Published private(set) var didFail: Bool = false
    @Published private(set) var isLoading: Bool = false
    @Published var selectedCofuStationId: String?

    @Published var cofuStationRadius: CLLocationDistance = 20_000 {
        didSet {
            fetchCofuStations()
        }
    }

    private let locationManager: LocationManager
    private var previousLocation: CLLocation?

    init() {
        locationManager = LocationManager()
        locationManager.delegate = self
    }

    func fetchCofuStations() {
        guard let location = previousLocation else {
            didFail = true
            return
        }

        isLoading = true

        Task { @MainActor [weak self] in
            guard let self = self else { return }

            let result = await POIKit.requestCofuGasStations(center: location, radius: self.cofuStationRadius)

            defer {
                self.isLoading = false
            }

            switch result {
            case .success(let detailedStations):
                self.didFail = detailedStations.isEmpty
                self.cofuStations = detailedStations.compactMap { .init(from: $0, at: location) }.sorted(by: { $0.distance < $1.distance })

            case .failure(let error):
                ExampleLogger.e("Failed fetching cofu stations with error \(error)")
                self.didFail = true
            }
        }
    }
}

extension ListViewModelImplementation: LocationManagerDelegate {
    func didUpdateLocations(locations: [CLLocation]) {
        guard let location = locations.last,
              previousLocation == nil || location.distance(from: previousLocation!) > 1000 else { return } // swiftlint:disable:this force_unwrapping

        previousLocation = location
        fetchCofuStations()
    }

    func didFail(with error: Error) {
        ExampleLogger.e("\(error)")
    }
}

struct ListGasStation {
    let id: String
    let name: String
    let addressLine1: String
    let addressLine2: String
    let distance: CLLocationDistance
    let formattedDistance: String

    init?(from poiStation: POIKit.GasStation, at location: CLLocation) {
        guard let id = poiStation.id else { return nil }

        self.id = id
        self.name = poiStation.stationName ?? "No Name"

        let address = poiStation.address

        self.addressLine1 = "\(address?.street ?? "") \(address?.houseNo ?? "")"
        self.addressLine2 = "\(address?.postalCode ?? "") \(address?.city ?? "")"

        guard let coordinate = poiStation.geometry.first?.location.coordinate else {
            self.distance = 0
            self.formattedDistance = ""
            return
        }

        self.distance = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude).distance(from: location)
        self.formattedDistance = distance.formattedDistance(fractionDigits: 1)
    }
}
