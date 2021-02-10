//
//  POIKitManager+Tiles.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

public extension POIKit.POIKitManager {
    func fetchPOIs(poisOfType: POIKit.POILayer,
                   boundingBox: POIKit.BoundingBox,
                   handler: @escaping (Result<[POIKit.GasStation], Error>) -> Void) -> CancellablePOIAPIRequest? {
        return api.fetchPOIs(poisOfType: poisOfType, boundingBox: boundingBox, handler: handler)
    }

    func loadPOIs(poisOfType: POIKit.POILayer,
                  boundingBox: POIKit.BoundingBox,
                  handler: @escaping (Result<[POIKit.GasStation], Error>) -> Void) -> CancellablePOIAPIRequest? {
        return api.loadPOIs(poisOfType: poisOfType, boundingBox: boundingBox, handler: handler)
    }

    func loadPOIs(uuids: [String], handler: @escaping (Result<[POIKit.GasStation], Error>) -> Void) -> CancellablePOIAPIRequest? {
        return api.loadPOIs(uuids: uuids, handler: handler)
    }
}
