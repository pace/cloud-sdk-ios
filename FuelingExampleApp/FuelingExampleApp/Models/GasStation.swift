//
//  GasStation.swift
//  PACECloudSDKFueling
//
//  Created by PACE Telematics GmbH.
//

import CoreLocation
import PACECloudSDK

struct GasStation {
    let id: String
    let name: String
    let addressLine1: String
    let addressLine2: String
    let distance: CLLocationDistance
    let formattedDistance: String
    let currency: String?

    init?(from poiStation: POIKit.GasStation, at location: CLLocation) {
        guard let id = poiStation.id else { return nil }

        self.id = id
        self.name = poiStation.stationName ?? "No Name"

        let address = poiStation.address

        self.addressLine1 = "\(address?.street ?? "") \(address?.houseNo ?? "")"
        self.addressLine2 = "\(address?.postalCode ?? "") \(address?.city ?? "")"

        self.currency = poiStation.currency

        guard let coordinate = poiStation.geometry.first?.location.coordinate else {
            self.distance = 0
            self.formattedDistance = ""
            return
        }

        self.distance = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude).distance(from: location)
        self.formattedDistance = distance.formattedDistance(fractionDigits: 1)
    }
}
