//
//  GeoAPIManager+Error.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

extension GeoAPIManager {
    enum GeoApiManagerError: Error {
        case invalidSpeed
        case requestCancelled
        case invalidResponse
        case unknownError
    }
}
