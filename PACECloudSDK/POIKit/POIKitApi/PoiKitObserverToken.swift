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

        weak var delegate: POIKitObserverTokenDelegate?
        let handler: (Bool, Swift.Result<[GasStation], Error>) -> Void

        @objc
        public dynamic func refresh(notOlderThan: Date?) {
            self.refreshTime = Date()
        }

        public func invalidate() {}

        init(delegate: POIKitObserverTokenDelegate?, handler: @escaping (Bool, Swift.Result<[GasStation], Error>) -> Void) {
            self.delegate = delegate
            self.handler = handler
        }
    }

    class BoundingBoxNotificationToken: PoiKitObserverToken {
        var token: AnyObject?
        var api: POIKitAPI
        var downloadTask: CancellablePOIAPIRequest?
        let zoomLevel: Int
        let forceLoad: Bool

        private (set) public var boundingBox: BoundingBox
        private let maxDistance: (distance: Double, padding: Double)?

        init(boundingBox: BoundingBox,
             api: POIKitAPI,
             delegate: POIKitObserverTokenDelegate? = nil,
             maxDistance: (distance: Double, padding: Double)? = nil,
             zoomLevel: Int = POIKitConfig.maxZoomLevel,
             forceLoad: Bool = false,
             handler: @escaping (Bool, Swift.Result<[GasStation], Error>) -> Void) {
            self.boundingBox = boundingBox
            self.api = api
            self.maxDistance = maxDistance

            let maxZoomLevel = POIKitConfig.maxZoomLevel
            self.zoomLevel = zoomLevel > maxZoomLevel ? maxZoomLevel : zoomLevel
            self.forceLoad = forceLoad

            super.init(delegate: delegate, handler: handler)

            self.token = self.delegate?.observe { isInitial, stations in
                self.updateStations(isInitial: isInitial, stations: stations)
            }
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
        }

        override public func invalidate() {
            self.token = nil
            self.delegate?.invalidateToken()
            self.delegate = nil
            self.downloadTask?.cancel()
        }
    }

    class UUIDNotificationToken: PoiKitObserverToken {
        var uuids: [String]
        var token: AnyObject?
        var api: POIKitAPI
        var downloadTask: CancellablePOIAPIRequest?

        init(uuids: [String], delegate: POIKitObserverTokenDelegate? = nil, api: POIKitAPI, handler: @escaping (Bool, Swift.Result<[GasStation], Error>) -> Void) {
            self.uuids = uuids
            self.api = api

            super.init(delegate: delegate, handler: handler)

            self.token = self.delegate?.observe(uuids: uuids) { change in
                self.updateStations(stations: change)
            }
        }

        func updateStations(stations: [GasStation]) {
            self.value = stations

            DispatchQueue.main.async {
                self.handler(false, .success(self.value))
            }
        }

        override public func invalidate() {
            self.token = nil
            delegate?.invalidateToken()
            delegate = nil
            self.downloadTask?.cancel()
        }
    }
}
