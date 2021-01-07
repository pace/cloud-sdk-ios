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
        var handler: (Bool, Swift.Result<[GasStation], Error>) -> Void

        @objc
        public dynamic func refresh(notOlderThan: Date?) {
            self.refreshTime = Date()
        }

        public func invalidate() {}

        init(delegate: POIKitObserverTokenDelegate, handler: @escaping (Bool, Swift.Result<[GasStation], Error>) -> Void) {
            self.delegate = delegate
            self.handler = handler
        }
    }

    class BoundingBoxNotificationToken: PoiKitObserverToken {
        private (set) public var boundingBox: BoundingBox
        var token: AnyObject?
        var api: POIKitAPI
        var downloadTask: URLSessionTask?

        init(delegate: POIKitObserverTokenDelegate,
             boundingBox: BoundingBox,
             api: POIKitAPI,
             maxDistance: (distance: Double, padding: Double)? = nil,
             handler: @escaping (Bool, Swift.Result<[GasStation], Error>) -> Void) {
            self.boundingBox = boundingBox
            self.api = api

            super.init(delegate: delegate, handler: handler)

            let allowedDiameter: Double
            if let maxDistance = maxDistance {
                allowedDiameter = maxDistance.distance * (1 + maxDistance.padding)
            } else {
                allowedDiameter = POIKitConfig.maxDistanceForDownloadJob
            }

            if boundingBox.diameter > allowedDiameter {
                handler(false, .failure(POIKitAPIError.searchDiameterTooLarge))
                return
            }

            self.token = self.delegate?.observe { isInitial, stations in
                self.updateStations(isInitial: isInitial, stations: stations)
            }
        }

        private func updateStations(isInitial: Bool, stations: [GasStation]) {
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
            delegate?.invalidateToken()
            self.downloadTask?.cancel()
        }
    }

    class UUIDNotificationToken: PoiKitObserverToken {
        var uuids: [String]
        var token: AnyObject?
        var api: POIKitAPI
        var downloadTask: URLSessionTask?

        init(delegate: POIKitObserverTokenDelegate, uuids: [String], api: POIKitAPI, handler: @escaping (Bool, Swift.Result<[GasStation], Error>) -> Void) {
            self.uuids = uuids
            self.api = api

            super.init(delegate: delegate, handler: handler)

            self.token = self.delegate?.observe(uuids: uuids) { change in
                self.value = change

                DispatchQueue.main.async {
                    self.handler(false, .success(self.value))
                }
            }
        }

        override public func invalidate() {
            self.token = nil
            delegate?.invalidateToken()
            self.downloadTask?.cancel()
        }
    }
}
