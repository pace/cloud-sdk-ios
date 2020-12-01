//
//  RegionalPriceRequest.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import CoreLocation

struct RegionalPriceRequest {
    var params: [String: [String]] {
        return [
            "filter[latitude]": ["\(coordinates.latitude)"],
            "filter[longitude]": ["\(coordinates.longitude)"]
        ]
    }

    var options: POIAPI.Prices.GetRegionalPrices.Request.Options {
        return POIAPI.Prices.GetRegionalPrices.Request
            .Options(filterlatitude: Float(coordinates.latitude),
                     filterlongitude: Float(coordinates.longitude))
    }

    private var coordinates: CLLocationCoordinate2D

    init(coordinates: CLLocationCoordinate2D) {
        self.coordinates = coordinates
    }
}
