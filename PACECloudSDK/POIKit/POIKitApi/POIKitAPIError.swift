//
//  POIKitAPIError.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

public extension POIKit {
    /** API Errors */
    enum POIKitAPIError: String, Error {
        case noError
        case unknown
        case serverError
        case serverUnreachable
        case tooManyRequests
        case networkError
        case searchDiameterTooLarge
        case zoomLevelTooLow
        case operationCanceledByClient
        case notFound
        case requestError
        case unauthorized
    }
}
