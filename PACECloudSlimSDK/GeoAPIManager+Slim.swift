//
//  GeoAPIManager+Slim.swift
//  PACECloudSlimSDK
//
//  Created by PACE Telematics GmbH.
//

import CoreLocation
import Foundation

class GeoAPIManager {
    var speedThreshold: Double = 0
    var geoAppsScope: String = ""

    func fetchPolygons() {}

    func locationBasedCofuStations(for location: CLLocation, result: @escaping (Result<[POIKit.CofuGasStation], GeoApiManagerError>) -> Void) {
        result(.failure(.unknown))
    }

    func cofuGasStations(option: POIKit.CofuGasStation.Option, result: @escaping (Result<[POIKit.CofuGasStation], GeoApiManagerError>) -> Void) {
        result(.failure(.unknown))
    }

    func decodeGeoAPIResponse(geoApiData: Data) -> GeoAPIResponse? { nil }

    func isPoiInRange(with id: String, near location: CLLocation, completion: @escaping (Bool) -> Void) {
        completion(false)
    }
}

public extension POIKit.CofuGasStation {
    enum Option {
        case all
        case boundingBox(center: CLLocation, radius: CLLocationDistance)
    }
}
