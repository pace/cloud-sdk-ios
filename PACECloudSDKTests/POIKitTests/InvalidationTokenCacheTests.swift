//
//  InvalidationTokenCacheTests.swift
//  PACECloudSDKTests
//
//  Created by PACE Telematics GmbH.
//

import XCTest
@testable import PACECloudSDK

class InvalidationTokenCacheTests: XCTestCase {
    private var cache = InvalidationTokenCache()
    private let zoomLevel: Int = 16
    private let initialBoundingBox = POIKit.BoundingBox(point1: .init(latitude: 49.03, longitude: 8.48), point2: .init(latitude: 48.98, longitude: 8.33), center: .init(latitude: 0, longitude: 0))

    func addInitialCacheItem() {
        let northEast = initialBoundingBox.point1.tileInformation(forZoomLevel: zoomLevel)
        let southWest = initialBoundingBox.point2.tileInformation(forZoomLevel: zoomLevel)
        let area = TileQueryRequest.AreaQuery(northEast: .init(information: northEast), southWest: .init(information: southWest), invalidationToken: nil)
        let coveredTiles = area.coveredTileInfo(for: zoomLevel)
        let tiles = coveredTiles.map { Tile(tileInformation: $0, type: .poi, invalidationToken: 100, data: .init(), created: Date(timeIntervalSince1970: 1)) }
        cache.add(tiles: tiles, for: zoomLevel)
    }

    func testRequestedTilesInCurrentBoundingBox() {
        addInitialCacheItem()

        // Smaller bounding box
        let requestedBoundingBox = POIKit.BoundingBox(point1: .init(latitude: 49.03, longitude: 8.45), point2: .init(latitude: 48.98, longitude: 8.35), center: .init(latitude: 0, longitude: 0))
        let northEast = requestedBoundingBox.point1.tileInformation(forZoomLevel: zoomLevel)
        let southWest = requestedBoundingBox.point2.tileInformation(forZoomLevel: zoomLevel)
        let area = TileQueryRequest.AreaQuery(northEast: .init(information: northEast), southWest: .init(information: southWest), invalidationToken: nil)
        let token = cache.invalidationToken(requestedArea: [area], for: zoomLevel)
        XCTAssertEqual(token, 100)
    }

    func testRequestedTilesNotInCurrentBoundingBox() {
        addInitialCacheItem()

        // Bigger bounding box
        let requestedBoundingBox = POIKit.BoundingBox(point1: .init(latitude: 49.04, longitude: 8.49), point2: .init(latitude: 48.98, longitude: 8.33), center: .init(latitude: 0, longitude: 0))
        let northEast = requestedBoundingBox.point1.tileInformation(forZoomLevel: zoomLevel)
        let southWest = requestedBoundingBox.point2.tileInformation(forZoomLevel: zoomLevel)
        let area = TileQueryRequest.AreaQuery(northEast: .init(information: northEast), southWest: .init(information: southWest), invalidationToken: nil)
        let token = cache.invalidationToken(requestedArea: [area], for: zoomLevel)
        XCTAssertNil(token)
    }

    func testRequestedTilesIsSameBoundingBox() {
        addInitialCacheItem()

        // Same bounding box
        let requestedBoundingBox = POIKit.BoundingBox(point1: .init(latitude: 49.03, longitude: 8.48), point2: .init(latitude: 48.98, longitude: 8.33), center: .init(latitude: 0, longitude: 0))
        let northEast = requestedBoundingBox.point1.tileInformation(forZoomLevel: zoomLevel)
        let southWest = requestedBoundingBox.point2.tileInformation(forZoomLevel: zoomLevel)
        let area = TileQueryRequest.AreaQuery(northEast: .init(information: northEast), southWest: .init(information: southWest), invalidationToken: nil)
        let token = cache.invalidationToken(requestedArea: [area], for: zoomLevel)
        XCTAssertEqual(token, 100)
    }

    func testOldestAvailableToken() {
        addInitialCacheItem() // 10x10

        // Bigger than initial
        let boundingBox1 = POIKit.BoundingBox(point1: .init(latitude: 49.04, longitude: 8.49), point2: .init(latitude: 48.98, longitude: 8.33), center: .init(latitude: 0, longitude: 0))
        let northEast1 = boundingBox1.point1.tileInformation(forZoomLevel: zoomLevel)
        let southWest1 = boundingBox1.point2.tileInformation(forZoomLevel: zoomLevel)
        let area1 = TileQueryRequest.AreaQuery(northEast: .init(information: northEast1), southWest: .init(information: southWest1), invalidationToken: nil)
        let coveredTiles1 = area1.coveredTileInfo(for: zoomLevel)
        let tiles1 = coveredTiles1.map { Tile(tileInformation: $0, type: .poi, invalidationToken: 101, data: .init(), created: Date(timeIntervalSince1970: 2)) }
        cache.add(tiles: tiles1, for: zoomLevel)

        // smaller than initial
        let boundingBox2 = POIKit.BoundingBox(point1: .init(latitude: 49.03, longitude: 8.45), point2: .init(latitude: 48.98, longitude: 8.35), center: .init(latitude: 0, longitude: 0))
        let northEast2 = boundingBox2.point1.tileInformation(forZoomLevel: zoomLevel)
        let southWest2 = boundingBox2.point2.tileInformation(forZoomLevel: zoomLevel)
        let area2 = TileQueryRequest.AreaQuery(northEast: .init(information: northEast2), southWest: .init(information: southWest2), invalidationToken: nil)
        let coveredTiles2 = area2.coveredTileInfo(for: zoomLevel)
        let tiles2 = coveredTiles2.map { Tile(tileInformation: $0, type: .poi, invalidationToken: 102, data: .init(), created: Date(timeIntervalSince1970: 3)) }
        cache.add(tiles: tiles2, for: zoomLevel)

        // Same bounding box 10.5x10.5
        let requestedBoundingBox = POIKit.BoundingBox(point1: .init(latitude: 49.02, longitude: 8.42), point2: .init(latitude: 48.99, longitude: 8.38), center: .init(latitude: 0, longitude: 0))
        let northEast = requestedBoundingBox.point1.tileInformation(forZoomLevel: zoomLevel)
        let southWest = requestedBoundingBox.point2.tileInformation(forZoomLevel: zoomLevel)
        let area = TileQueryRequest.AreaQuery(northEast: .init(information: northEast), southWest: .init(information: southWest), invalidationToken: nil)
        let token = cache.invalidationToken(requestedArea: [area], for: zoomLevel)
        XCTAssertEqual(token, 102) // 100 was overwritten by 102 (same tile)
    }

    func testMultipleSmallerBoundingBoxes() {
        // Left bounding box
        let boundingBox1 = POIKit.BoundingBox(point1: .init(latitude: 49.04, longitude: 8.38), point2: .init(latitude: 48.96, longitude: 8.31), center: .init(latitude: 0, longitude: 0))
        let northEast1 = boundingBox1.point1.tileInformation(forZoomLevel: zoomLevel)
        let southWest1 = boundingBox1.point2.tileInformation(forZoomLevel: zoomLevel)
        let area1 = TileQueryRequest.AreaQuery(northEast: .init(information: northEast1), southWest: .init(information: southWest1), invalidationToken: nil)
        let coveredTiles1 = area1.coveredTileInfo(for: zoomLevel)
        let tiles1 = coveredTiles1.map { Tile(tileInformation: $0, type: .poi, invalidationToken: 100, data: .init(), created: Date(timeIntervalSince1970: 1)) }
        cache.add(tiles: tiles1, for: zoomLevel)

        // Middle bounding box
        let boundingBox2 = POIKit.BoundingBox(point1: .init(latitude: 49.04, longitude: 8.44), point2: .init(latitude: 48.96, longitude: 8.37), center: .init(latitude: 0, longitude: 0))
        let northEast2 = boundingBox2.point1.tileInformation(forZoomLevel: zoomLevel)
        let southWest2 = boundingBox2.point2.tileInformation(forZoomLevel: zoomLevel)
        let area2 = TileQueryRequest.AreaQuery(northEast: .init(information: northEast2), southWest: .init(information: southWest2), invalidationToken: nil)
        let coveredTiles2 = area2.coveredTileInfo(for: zoomLevel)
        let tiles2 = coveredTiles2.map { Tile(tileInformation: $0, type: .poi, invalidationToken: 101, data: .init(), created: Date(timeIntervalSince1970: 2)) }
        cache.add(tiles: tiles2, for: zoomLevel)

        // Right bounding box
        let boundingBox3 = POIKit.BoundingBox(point1: .init(latitude: 49.04, longitude: 8.5), point2: .init(latitude: 48.96, longitude: 8.42), center: .init(latitude: 0, longitude: 0))
        let northEast3 = boundingBox3.point1.tileInformation(forZoomLevel: zoomLevel)
        let southWest3 = boundingBox3.point2.tileInformation(forZoomLevel: zoomLevel)
        let area3 = TileQueryRequest.AreaQuery(northEast: .init(information: northEast3), southWest: .init(information: southWest3), invalidationToken: nil)
        let coveredTiles3 = area3.coveredTileInfo(for: zoomLevel)
        let tiles3 = coveredTiles3.map { Tile(tileInformation: $0, type: .poi, invalidationToken: 102, data: .init(), created: Date(timeIntervalSince1970: 3)) }
        cache.add(tiles: tiles3, for: zoomLevel)

        // Within all of the three bounding boxes
        let requestedBoundingBox = POIKit.BoundingBox(point1: .init(latitude: 49.03, longitude: 8.48), point2: .init(latitude: 48.98, longitude: 8.33), center: .init(latitude: 0, longitude: 0))
        let requestedNorthEast = requestedBoundingBox.point1.tileInformation(forZoomLevel: zoomLevel)
        let requestedSouthWest = requestedBoundingBox.point2.tileInformation(forZoomLevel: zoomLevel)
        let requestedArea = TileQueryRequest.AreaQuery(northEast: .init(information: requestedNorthEast), southWest: .init(information: requestedSouthWest), invalidationToken: nil)
        let token = cache.invalidationToken(requestedArea: [requestedArea], for: zoomLevel)
        XCTAssertEqual(token, 100)
    }

    func test10_000Tiles() {
        measure {
            // ~10_000 tiles
            let boundingBox = POIKit.BoundingBox(point1: .init(latitude: 49.14, longitude: 8.79), point2: .init(latitude: 48.86, longitude: 8.04), center: .init(latitude: 0, longitude: 0))
            let northEast = boundingBox.point1.tileInformation(forZoomLevel: zoomLevel)
            let southWest = boundingBox.point2.tileInformation(forZoomLevel: zoomLevel)
            let area = TileQueryRequest.AreaQuery(northEast: .init(information: northEast), southWest: .init(information: southWest), invalidationToken: nil)
            let coveredTiles = area.coveredTileInfo(for: zoomLevel)
            let tiles = coveredTiles.map { Tile(tileInformation: $0, type: .poi, invalidationToken: 100, data: .init(), created: Date(timeIntervalSince1970: 1)) }
            cache.add(tiles: tiles, for: zoomLevel)

            // Slightly smaller bounding box
            let requestedBoundingBox = POIKit.BoundingBox(point1: .init(latitude: 49.12, longitude: 8.77), point2: .init(latitude: 48.87, longitude: 8.06), center: .init(latitude: 0, longitude: 0))
            let requestedNorthEast = requestedBoundingBox.point1.tileInformation(forZoomLevel: zoomLevel)
            let requestedSouthWest = requestedBoundingBox.point2.tileInformation(forZoomLevel: zoomLevel)
            let requestedArea = TileQueryRequest.AreaQuery(northEast: .init(information: requestedNorthEast), southWest: .init(information: requestedSouthWest), invalidationToken: nil)
            let _ = cache.invalidationToken(requestedArea: [requestedArea], for: zoomLevel)
        }
    }

    func test20_000Tiles() {
        measure {
            // ~20_000 tiles
            let boundingBox = POIKit.BoundingBox(point1: .init(latitude: 49.22, longitude: 8.91), point2: .init(latitude: 48.82, longitude: 7.88), center: .init(latitude: 0, longitude: 0))
            let northEast = boundingBox.point1.tileInformation(forZoomLevel: zoomLevel)
            let southWest = boundingBox.point2.tileInformation(forZoomLevel: zoomLevel)
            let area = TileQueryRequest.AreaQuery(northEast: .init(information: northEast), southWest: .init(information: southWest), invalidationToken: nil)
            let coveredTiles = area.coveredTileInfo(for: zoomLevel)
            let tiles = coveredTiles.map { Tile(tileInformation: $0, type: .poi, invalidationToken: 100, data: .init(), created: Date(timeIntervalSince1970: 1)) }
            cache.add(tiles: tiles, for: zoomLevel)

            // Slightly smaller bounding box
            let requestedBoundingBox = POIKit.BoundingBox(point1: .init(latitude: 49.12, longitude: 8.77), point2: .init(latitude: 48.87, longitude: 8.06), center: .init(latitude: 0, longitude: 0))
            let requestedNorthEast = requestedBoundingBox.point1.tileInformation(forZoomLevel: zoomLevel)
            let requestedSouthWest = requestedBoundingBox.point2.tileInformation(forZoomLevel: zoomLevel)
            let requestedArea = TileQueryRequest.AreaQuery(northEast: .init(information: requestedNorthEast), southWest: .init(information: requestedSouthWest), invalidationToken: nil)
            let _ = cache.invalidationToken(requestedArea: [requestedArea], for: zoomLevel)
        }
    }
}
