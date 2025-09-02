//
//  GeoAPIManagerError.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

enum GeoApiManagerError: Error {
    case invalidURL
    case invalidSpeed
    case requestCancelled
    case notModified
    case invalidResponse
    case unexpectedStatusCode(statusCode: Int)
    case unknown
    case lastFetchedThresholdNotMet
    case decoding(Error)
    case network(Error)
    case database(Error)
}
