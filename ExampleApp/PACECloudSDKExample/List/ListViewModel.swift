//
//  ListViewModel.swift
//  PACECloudSDKExample
//
//  Created by Patrick Niepel on 05.11.20.
//

import CoreLocation
import Foundation
import PACECloudSDK

class ListViewModel: NSObject {
    var listItems: LiveData<[ListItem]> = .init()
    var isLoading: LiveData<Bool> = .init(value: false)

    private var poiKitManager: POIKit.POIKitManager
    private var locationManager: CLLocationManager?
    private var downloadTask: URLSessionTask?

    private var currentLocation: CLLocation? {
        locationManager?.location
    }

    override init() {
        #if PRODUCTION
        poiKitManager = POIKit.POIKitManager(environment: .production)
        #elseif STAGE
        poiKitManager = POIKit.POIKitManager(environment: .stage)
        #elseif SANDBOX
        poiKitManager = POIKit.POIKitManager(environment: .sandbox)
        #else
        poiKitManager = POIKit.POIKitManager(environment: .development)
        #endif

        super.init()

        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
    }

    func fetchCoFuStations() {
        guard let coordinate = currentLocation?.coordinate else { return }

        downloadTask?.cancel()
        isLoading.value = true

        downloadTask = poiKitManager.fetchPOIs(poisOfType: .gasStation, boundingBox: POIKit.BoundingBox(center: coordinate, radius: 25_000)) { [weak self] result in

            defer {
                self?.isLoading.value = false
            }

            switch result {
            case .failure(let error):
                NSLog("Failed fetching stations with error \(error)")
                self?.listItems.value = []

            case .success(let stations):
                let cofuStations = stations.filter { $0.isConnectedFuelingAvailable }

                var distances: [(Int, CLLocationDistance)] = cofuStations.enumerated().compactMap { index, station in
                    guard let latitude = station.attributes?.latitude,
                          let longitude = station.attributes?.longitude
                    else { return nil }

                    let location = CLLocation(latitude: Double(latitude), longitude: Double(longitude))

                    guard let distance = self?.currentLocation?.distance(from: location) else { return nil }

                    return (index, distance)
                }

                distances = Array(distances.sorted(by: { $0.1 < $1.1 }))

                let items: [ListItem] = distances.compactMap {
                    ListItem(from: cofuStations[$0.0], distance: $0.1)
                }

                self?.listItems.value = items
            }
        }
    }
}

extension ListViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse || status == .authorizedWhenInUse else { return }
        fetchCoFuStations()
    }
}

struct ListItem {
    let name: String
    let street: String
    let houseNo: String
    let city: String
    let postalCode: String
    let distance: Double
    let coordinate: CLLocationCoordinate2D

    init?(from gasStation: POIKit.GasStation, distance: Double) {
        guard let coordinate = gasStation.coordinate else { return nil }

        self.name = gasStation.attributes?.stationName ?? "No name"
        self.street = gasStation.attributes?.address?.street ?? "No street"
        self.houseNo = gasStation.attributes?.address?.houseNo ?? "No houseNo"
        self.city = gasStation.attributes?.address?.city ?? "No City"
        self.postalCode = gasStation.attributes?.address?.postalCode ?? "No zip code"
        self.distance = distance
        self.coordinate = coordinate
    }
}
