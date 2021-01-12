//
//  PoiKitObserverToken.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

public extension POIKit.BoundingBoxNotificationToken {
    override func refresh(notOlderThan: Date?) {
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

        refreshTime = Date()
    }
}

public extension POIKit.UUIDNotificationToken {
    override func refresh(notOlderThan: Date?) {
        // Build request from bounding box
        guard let delegate = POIKit.Database.shared.delegate else { return }

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

        refreshTime = Date()
    }
}
