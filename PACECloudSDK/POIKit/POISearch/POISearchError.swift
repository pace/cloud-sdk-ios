//
//  POISearchError.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

/**
 Different error states that can occur during a POI search.
 */
public enum POISearchError: Error {
    case undefined
    case boundingBoxMismatch
    case exceededMaximumSearchBoxSize
    case network
}
