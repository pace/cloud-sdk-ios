//
//  POIKitApiProtocol.swift
//  PACECloudSlimSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

extension POIKitAPIProtocol {
    func fetchPOIs(poisOfType: POIKit.POILayer,
                   boundingBox: POIKit.BoundingBox,
                   forceLoad: Bool = false,
                   handler: @escaping (Result<[POIKit.GasStation], Error>) -> Void) -> CancellablePOIAPIRequest? {
        nil
    }

    func loadPOIs(poisOfType: POIKit.POILayer,
                  boundingBox: POIKit.BoundingBox,
                  forceLoad: Bool = false,
                  handler: @escaping (Result<[POIKit.GasStation], Error>) -> Void) -> CancellablePOIAPIRequest? {
        nil
    }

    func loadPOIs(uuids: [String],
                  handler: @escaping (Result<[POIKit.GasStation], Error>) -> Void) -> CancellablePOIAPIRequest? {
        nil
    }
}
