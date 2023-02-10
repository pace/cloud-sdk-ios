//
//  PoiKitObserverToken.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

public extension POIKit {
    class PoiKitObserverToken {
        public var value: [GasStation] = []
        public var error: Error?
        public var refreshTime: Date?

        public var isLoading: Observable<Bool> = .init(value: false)

        let handler: (Bool, Swift.Result<[GasStation], Error>) -> Void

        @objc
        public dynamic func refresh(notOlderThan: Date?) {
            self.refreshTime = Date()
        }

        public func invalidate() {}

        init(handler: @escaping (Bool, Swift.Result<[GasStation], Error>) -> Void) {
            self.handler = handler
        }
    }

    class BoundingBoxNotificationToken: PoiKitObserverToken {
        var api: POIKitAPI
        var downloadTask: CancellablePOIAPIRequest?
        let zoomLevel: Int
        let forceLoad: Bool

        var receivedInvalidationToken: UInt64?
        var didCallHandler: Bool = false

        private (set) public var boundingBox: BoundingBox
        private let maxDistance: (distance: Double, padding: Double)?

        init(boundingBox: BoundingBox,
             api: POIKitAPI,
             maxDistance: (distance: Double, padding: Double)? = nil,
             zoomLevel: Int = POIKitConfig.minZoomLevelFullDetails,
             forceLoad: Bool = false,
             handler: @escaping (Bool, Swift.Result<[GasStation], Error>) -> Void) {
            self.boundingBox = boundingBox
            self.api = api
            self.maxDistance = maxDistance

            let maxZoomLevel = POIKitConfig.maxZoomLevel
            self.zoomLevel = zoomLevel > maxZoomLevel ? maxZoomLevel : zoomLevel
            self.forceLoad = forceLoad

            super.init(handler: handler)
        }

        func isDiameterValid() -> Bool {
            // Only check diameter if != nil
            if let maxDistanceTuple = maxDistance {
                let allowedDiameter = maxDistanceTuple.distance * (1 + maxDistanceTuple.padding)

                if boundingBox.diameter > allowedDiameter {
                    handler(false, .failure(POIKitAPIError.searchDiameterTooLarge))
                    return false
                }
            }

            return true
        }

        func isZoomLevelValid() -> Bool {
            if zoomLevel < POIKitConfig.minZoomLevel {
                handler(false, .failure(POIKitAPIError.zoomLevelTooLow))
                return false
            }

            return true
        }

        func updateStations(isInitial: Bool, stations: [GasStation]) {
            self.value = stations.filter {
                guard let coord = $0.coordinate else { return false }

                return boundingBox.contains(coord: coord)
            }

            DispatchQueue.main.async {
                self.handler(isInitial, .success(self.value))
            }

            didCallHandler = true
        }

        override public func invalidate() {
            self.downloadTask?.cancel()
            self.downloadTask = nil

            if !didCallHandler, let receivedInvalidationToken = receivedInvalidationToken {
                self.api.invalidationTokenCache.remove(receivedInvalidationToken, for: zoomLevel)
            }
        }
    }
}
