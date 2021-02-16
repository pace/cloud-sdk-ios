//
//  InvalidationTokenCache.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

class InvalidationTokenCache {
    // [ZoomLevel: [TileId: TokenItem]]
    private var cacheItems: [Int: [String: TokenItem]] = [:]

    func add(tiles: [Tile], for zoomLevel: Int) {
        tiles.forEach {
            if cacheItems[zoomLevel] == nil {
                cacheItems[zoomLevel] = [$0.tileId: TokenItem(creationDate: $0.created, invalidationToken: $0.invalidationToken)]
            } else {
                cacheItems[zoomLevel]?[$0.tileId] = TokenItem(creationDate: $0.created, invalidationToken: $0.invalidationToken)
            }
        }
    }

    func invalidationToken(requestedArea: [TileQueryRequest.AreaQuery], for zoomLevel: Int) -> UInt64? {
        let requestedTileInfos = requestedArea.flatMap { $0.coveredTileInfo(for: zoomLevel) }
        let requestedIDs = Set(requestedTileInfos.map { $0.id })

        let cachedItems = cacheItems[zoomLevel] ?? [:]

        // Return nil if there is an requested id that is not in the cache yet
        guard requestedIDs.filter({ cachedItems[$0] == nil }).isEmpty else { return nil }

        // All requested tiles are contained in the already cached tiles
        // Get oldest token by sorting tiles by their creation date
        let affectedTiles = requestedIDs.compactMap { cachedItems[$0] }.sorted(by: { $0.creationDate < $1.creationDate })

        let token = affectedTiles.first?.invalidationToken
        return token
    }

    private struct TokenItem: Hashable {
        let creationDate: Date
        let invalidationToken: UInt64
    }
}
