//
//  POIKitConfig.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

struct POIKitConfig {
    // MARK: - Database & Download
    /// Remove too many tiles every 100 times only.
    static let databaseCleanInterval = 100

    /// Max number of download jobs in the tile downloading queue.
    static let maxDownloadJobsInQueue = 60

    /// Max number of download jobs in the poi downloading queue
    static let maxPOIDownloadJobsInQueue = 2

    /// Max distance in meters of download job in tile downloading queue
    static let maxDistanceForDownloadJob = 20_000.0

    /// Maximum number of road tiles in cache
    static let maxRoadTilesInCache = 10

    /// Default time to live for road tiles is 7 days.
    static let roadTileTimeToLive = 7 * 24 * 60 * 60

    /// Default time to live for POI tiles is 10 minutes.
    static let poiTileTimeToLive = 10 * 60

    /// Time to live for failed tiles is 2 minutes.
    static let failedTileTimeToLive = 2 * 60

    // MARK: - Tile Loading
    /**
     * POI service:
     * If the number of tiles we want to download is less than the given threshold, use individual queries instead of area queries.
     */
    static let individualVsAreaQueryThreashold = 6

    // MARK: - HTTP Requests
    /// URL Session connection timeout in seconds
    static let connectTimeout = 30.0

    /// URL Session read timeout in seconds.
    static let readTimeout = 30.0

    // MARK: - POI Search
    /// POI search request boxes cannot be larger than 20 km (measuring from southeast to northwest points).
    static let maxPoiSearchBoxSize = 20_000.0

    // MARK: - Others
    /// Zoom level of Open Street Map tiles.
    static let zoomLevel = 15

    /// Earth radius in kilometers
    static let earthRadiusInKilometers = 6371.0
}
