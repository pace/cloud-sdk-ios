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
                   handler: @escaping (Result<[POIKit.GasStation], Error>) -> Void) -> URLSessionTask? {
        nil
    }

    func loadPOIs(poisOfType: POIKit.POILayer,
                  boundingBox: POIKit.BoundingBox,
                  handler: @escaping (Result<[POIKit.GasStation], Error>) -> Void) -> URLSessionTask? {
        nil
    }

    func loadPOIs(uuids: [String],
                  handler: @escaping (Result<[POIKit.GasStation], Error>) -> Void) -> URLSessionTask? {
        nil
    }
}