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

        public func refresh(notOlderThan: Date?) {
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
        private var token: AnyObject?
        private var api: POIKitAPI
        private var downloadTask: URLSessionTask?

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

        override public func refresh(notOlderThan: Date?) {
            guard token != nil else { return }

            isLoading.value = true

            // Build request from bounding box
            let zoomLevel = POIKitConfig.zoomLevel
            let northEast = boundingBox.point1.tileInformation(forZoomLevel: zoomLevel)
            let southWest = boundingBox.point2.tileInformation(forZoomLevel: zoomLevel)
            let tileRequest = TileQueryRequest(areas: [TileQueryRequest.AreaQuery(northEast: TileQueryRequest.Coordinate(information: northEast),
                                                                                  southWest: TileQueryRequest.Coordinate(information: southWest),
                                                                                  invalidationToken: nil)], zoomLevel: UInt32(zoomLevel))

            downloadTask = api.loadPois(tileRequest) { [weak self] result in
                switch result {
                case .failure(let error):
                    self?.handler(false, .failure(error))

                case .success(let tiles):
                    // Save to database
                    self?.api.save(tiles, for: self?.boundingBox)
                }

                self?.isLoading.value = false
            }

            super.refresh(notOlderThan: notOlderThan)
        }

        override public func invalidate() {
            self.token = nil
            delegate?.invalidateToken()
            self.downloadTask?.cancel()
        }
    }

    class UUIDNotificationToken: PoiKitObserverToken {
        private var uuids: [String]
        private var token: AnyObject?
        private var api: POIKitAPI
        private var downloadTask: URLSessionTask?

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

        override public func refresh(notOlderThan: Date?) {
            // Build request from bounding box
            guard let delegate = Database.shared.delegate else { return }

            let zoomLevel = POIKitConfig.zoomLevel
            let tiles = delegate
                .get(uuids: uuids)
                .filter {
                    if let lastUpdated = $0.lastUpdated, let notOlderThan = notOlderThan {
                        return lastUpdated < notOlderThan
                    } else {
                        return true
                    }
                }
                .compactMap { $0.coordinate?.tileCoordinate(withZoom: zoomLevel) }
                .map { TileQueryRequest.IndividualTileQuery(information: TileInformation(zoomLevel: zoomLevel, x: $0.x, y: $0.y), invalidationToken: nil) }

            let tileRequest = TileQueryRequest(tiles: tiles, zoomLevel: UInt32(zoomLevel))

            downloadTask = api.loadPois(tileRequest) { result in
                switch result {
                case .failure(let error):
                    self.handler(false, .failure(error))

                case .success(let tiles):
                    // Save to database
                    self.api.save(tiles)
                }
            }

            super.refresh(notOlderThan: notOlderThan)
        }

        override public func invalidate() {
            self.token = nil
            delegate?.invalidateToken()
            self.downloadTask?.cancel()
        }
    }
}
