//
//  POIKitManager+Tiles.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import CoreLocation
import Foundation

public extension POIKit.POIKitManager {
    /**
     Fetches the gas stations within the specified bounding box.
     - parameter boundingBox: The bounding box the gas stations will be retrieved for.
     - parameter forceLoad: If `false` the response may only include gas stations that have been changed since the previous request. Defaults to `false`.
     - parameter handler: The block to be called when the request has been completed either containing a list of gas stations or an error.
     - returns: The request's session task.
     */
    func fetchPOIs(boundingBox: POIKit.BoundingBox,
                   forceLoad: Bool = false,
                   handler: @escaping (Result<[POIKit.GasStation], Error>) -> Void) -> CancellablePOIAPIRequest? {
        return api.fetchPOIs(boundingBox: boundingBox, forceLoad: forceLoad, handler: handler)
    }

    /**
     Fetches the gas stations that are contained in the map tiles for the specified locations.

     The response will additionally invoke POIDatabaseDelegate's `add(_ gasStations: [POIKit.GasStation])` which can be used to persist stations into your database if desired.

     - parameter locations: The locations the gas stations will be retrieved for.
     - parameter handler: The block to be called when the request has been completed either containing a list of gas stations or an error.
     - returns: The request's session task.
     */
    func fetchPOIs(locations: [CLLocation], handler: @escaping (Result<[POIKit.GasStation], Error>) -> Void) -> CancellablePOIAPIRequest? {
        return api.fetchPOIs(locations: locations, handler: handler)
    }

    /**
     Fetches gas stations within the specified bounding box.

     You will only get a valid response if the `POIDatabaseDelegate` has been set up via `POIKit.setDatabaseDelegate(_ delegate: POIDatabaseDelegate)`.

     - parameter boundingBox: The bounding box the gas stations will be retrieved for.
     - parameter forceLoad: If `false` the response may only include gas stations that have been changed since the previous request. Defaults to `false`.
     - parameter handler: The block to be called when the request has been completed either containing a list of gas stations or an error.
     - returns: The request's session task.
     */
    func loadPOIs(boundingBox: POIKit.BoundingBox,
                  forceLoad: Bool = false,
                  handler: @escaping (Result<[POIKit.GasStation], Error>) -> Void) -> CancellablePOIAPIRequest? {
        return api.loadPOIs(boundingBox: boundingBox, forceLoad: forceLoad, handler: handler)
    }

    /**
     Fetches gas stations within the specified bounding box.

     You will only get a valid response if the `POIDatabaseDelegate` has been set up via `POIKit.setDatabaseDelegate(_ delegate: POIDatabaseDelegate)`.

     - parameter uuids: The list of gas station uuids to be retrieved.
     - parameter handler: The block to be called when the request has been completed either containing a list of gas stations or an error.
     - returns: The request's session task.
     */
    func loadPOIs(uuids: [String], handler: @escaping (Result<[POIKit.GasStation], Error>) -> Void) -> CancellablePOIAPIRequest? {
        return api.loadPOIs(uuids: uuids, handler: handler)
    }
}
