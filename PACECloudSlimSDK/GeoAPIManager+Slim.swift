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

    func cofuGasStations(for location: CLLocation? = nil, result: @escaping (Result<[CofuGasStation], GeoApiManagerError>) -> Void) {
        result(.failure(.unknownError))
    }

    func decodeGeoAPIResponse(geoApiData: Data) -> GeoAPIResponse? { nil }

    func isPoiInRange(with id: String, near location: CLLocation, completion: @escaping (Bool) -> Void)  {
        completion(false)
    }
}
