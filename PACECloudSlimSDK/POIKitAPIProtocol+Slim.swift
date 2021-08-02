//
//  POIKitApiProtocol.swift
//  PACECloudSlimSDK
//
//  Created by PACE Telematics GmbH.
//

import CoreLocation
import Foundation

extension POIKitAPIProtocol {
    func fetchPOIs(boundingBox: POIKit.BoundingBox,
                   forceLoad: Bool = false,
                   handler: @escaping (Result<[POIKit.GasStation], Error>) -> Void) -> CancellablePOIAPIRequest? {
        nil
    }

    func fetchPOIs(locations: [CLLocation],
                  handler: @escaping (Result<[POIKit.GasStation], Error>) -> Void) -> CancellablePOIAPIRequest? {
        nil
    }

    func loadPOIs(boundingBox: POIKit.BoundingBox,
                  forceLoad: Bool = false,
                  handler: @escaping (Result<[POIKit.GasStation], Error>) -> Void) -> CancellablePOIAPIRequest? {
        nil
    }

    func loadPOIs(uuids: [String],
                  handler: @escaping (Result<[POIKit.GasStation], Error>) -> Void) -> CancellablePOIAPIRequest? {
        nil
    }
}
