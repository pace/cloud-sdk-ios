//
//  POIKitAPI+Observer.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

extension POIKitAPI {
    func observe(delegate: POIKitObserverTokenDelegate,
                 uuids: [String],
                 handler: @escaping (Bool, Swift.Result<[POIKit.GasStation], Error>) -> Void) -> POIKit.UUIDNotificationToken {
        POIKit.UUIDNotificationToken(delegate: delegate, uuids: uuids, api: self, handler: handler)
    }

    func observe(delegate: POIKitObserverTokenDelegate,
                 poisOfType: POIKit.POILayer,
                 boundingBox: POIKit.BoundingBox,
                 maxDistance: (distance: Double, padding: Double)? = nil,
                 handler: @escaping (Bool, Swift.Result<[POIKit.GasStation], Error>) -> Void) -> POIKit.BoundingBoxNotificationToken {
        POIKit.BoundingBoxNotificationToken(delegate: delegate, boundingBox: boundingBox, api: self, maxDistance: maxDistance, handler: handler)
    }
}
