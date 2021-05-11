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

    func apps(for location: CLLocation, result: @escaping (Result<[GeoGasStation], GeoApiManagerError>) -> Void) {
        result(.failure(.unknownError))
    }

    func isPoiInRange(with id: String, near location: CLLocation, completion: @escaping (Bool) -> Void)  {
        completion(false)
    }
}
