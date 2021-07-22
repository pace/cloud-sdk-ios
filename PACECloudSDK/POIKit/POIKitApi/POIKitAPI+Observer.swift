//
//  POIKitAPI+Observer.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

extension POIKitAPI {
    func observe(uuids: [String],
                 delegate: POIKitObserverTokenDelegate? = nil,
                 handler: @escaping (Bool, Swift.Result<[POIKit.GasStation], Error>) -> Void) -> POIKit.UUIDNotificationToken {
        POIKit.UUIDNotificationToken(uuids: uuids, delegate: delegate, api: self, handler: handler)
    }

    func observe(poisOfType: POIKit.POILayer,
                 boundingBox: POIKit.BoundingBox,
                 delegate: POIKitObserverTokenDelegate? = nil,
                 maxDistance: (distance: Double, padding: Double)? = nil,
                 zoomLevel: Int? = nil,
                 forceLoad: Bool = false,
                 handler: @escaping (Bool, Swift.Result<[POIKit.GasStation], Error>) -> Void) -> POIKit.BoundingBoxNotificationToken {

        let zoomLevel = zoomLevel ?? POIKitConfig.minZoomLevelFullDetails
        let token = POIKit.BoundingBoxNotificationToken(boundingBox: boundingBox,
                                                        api: self,
                                                        delegate: delegate,
                                                        maxDistance: maxDistance,
                                                        zoomLevel: zoomLevel,
                                                        forceLoad: forceLoad,
                                                        handler: handler)

        return token
    }
}
