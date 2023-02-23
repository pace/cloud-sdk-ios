//
//  PoiKitObserverToken.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

public extension POIKit.BoundingBoxNotificationToken {
    override func refresh(notOlderThan: Date?) {
        guard isDiameterValid() && isZoomLevelValid() else { return }

        isLoading.value = true
        didCallHandler = false

        // Build request from bounding box
        let zoomLevel = self.zoomLevel
        let northEast = boundingBox.point1.tileInformation(forZoomLevel: zoomLevel)
        let southWest = boundingBox.point2.tileInformation(forZoomLevel: zoomLevel)
        var area = TileQueryRequest.AreaQuery(northEast: TileQueryRequest.Coordinate(information: northEast), southWest: TileQueryRequest.Coordinate(information: southWest))

        if !forceLoad, let invalidationToken = api.invalidationTokenCache.invalidationToken(requestedArea: [area], for: zoomLevel) {
            area.invalidationToken = invalidationToken
        }

        let tileRequest = TileQueryRequest(areas: [area], zoomLevel: UInt32(zoomLevel))

        downloadTask = api.loadPois(tileRequest) { [weak self] result in
            switch result {
            case .failure(let error):
                self?.handler(false, .failure(error))

            case .success(let poiResponse):
                let tilesResponse = poiResponse.tilesResponse
                let tiles = tilesResponse.tiles
                let pois = poiResponse.pois

                self?.receivedInvalidationToken = tiles.first?.invalidationToken
                self?.api.invalidationTokenCache.add(tiles: tiles, for: tilesResponse.zoomLevel)

                self?.updateStations(isInitial: false, stations: pois)
            }

            self?.isLoading.value = false
        }

        POIKitLogger.d("Requesting pois for zoom level \(zoomLevel)")

        super.refresh(notOlderThan: notOlderThan)
    }
}
