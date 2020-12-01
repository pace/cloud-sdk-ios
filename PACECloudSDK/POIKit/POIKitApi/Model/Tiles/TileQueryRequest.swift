//
//  TileQueryRequest.swift
//  PACEMapKit
//
//  Created by PACE Telematics GmbH.
//

import Foundation

extension TileQueryRequest {

    init(tiles: [IndividualTileQuery], zoomLevel: UInt32) {
        self.tiles = tiles
        self.zoom = zoomLevel
    }

    init(areas: [AreaQuery], zoomLevel: UInt32) {
        self.areas = areas
        self.zoom = zoomLevel
    }

}

extension TileQueryRequest.AreaQuery {

    init(northEast: TileQueryRequest.Coordinate, southWest: TileQueryRequest.Coordinate, invalidationToken: Int64?) {
        if let invalidationToken = invalidationToken, invalidationToken > 0 { self.invalidationToken = UInt64(invalidationToken) }
        self.northEast = northEast
        self.southWest = southWest
    }

    var coveredTileInfo: [TileInformation] {
        let xMin = southWest.x
        let yMin = northEast.y
        let xMax = northEast.x
        let yMax = southWest.y

        var result: [TileInformation] = []
        guard xMin < xMax, yMin < yMax else { return result }

        for x in (xMin...xMax) {
            for y in (yMin...yMax) {
                result.append(TileInformation(zoomLevel: POIKitConfig.zoomLevel, x: Int(x), y: Int(y)))
            }
        }
        return result
    }

}

extension TileQueryRequest.IndividualTileQuery {

    init(information: TileInformation, invalidationToken: Int64?) {
        if let invalidationToken = invalidationToken, invalidationToken > 0 { self.invalidationToken = UInt64(invalidationToken) }
        self.geo = TileQueryRequest.Coordinate(information: information)
    }

    var tileInfo: TileInformation {
        return TileInformation(zoomLevel: POIKitConfig.zoomLevel, x: Int(geo.x), y: Int(geo.y))
    }

}

extension TileQueryRequest.Coordinate {

    init(information: TileInformation) {
        self.x = UInt32(information.x)
        self.y = UInt32(information.y)
    }

    init(x: Int, y: Int) {
        self.x = UInt32(x)
        self.y = UInt32(y)
    }

}
