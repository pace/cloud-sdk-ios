//
//  POIFiltersRequest.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import CoreLocation

struct POIFiltersRequest {
    var params: [String: [String]] {
        return [
            "latitude": ["\(coordinates.latitude)"],
            "longitude": ["\(coordinates.longitude)"]
        ]
    }

    var options: POIAPI.MetadataFilters.GetMetadataFilters.Request.Options {
        return POIAPI.MetadataFilters
            .GetMetadataFilters
            .Request
            .Options(latitude: Float(coordinates.latitude), longitude: Float(coordinates.longitude))
    }

    private var coordinates: CLLocationCoordinate2D

    init(coordinates: CLLocationCoordinate2D) {
        self.coordinates = coordinates
    }
}
