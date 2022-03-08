//
//  PKMapsAPI+VectorTiles.swift
//  PACEMapKit
//
//  Created by PACE Telematics GmbH.
//

import CoreLocation
import UIKit

// MARK: - Retrieving pois without needing a database
extension POIKitAPI {
    func fetchPOIs(boundingBox: POIKit.BoundingBox,
                   forceLoad: Bool = false,
                   handler: @escaping (Swift.Result<[POIKit.GasStation], Error>) -> Void) -> CancellablePOIAPIRequest? {
        let zoomLevel = POIKitConfig.minZoomLevelFullDetails
        let northEast = boundingBox.point1.tileInformation(forZoomLevel: zoomLevel)
        let southWest = boundingBox.point2.tileInformation(forZoomLevel: zoomLevel)
        var area = TileQueryRequest.AreaQuery(northEast: TileQueryRequest.Coordinate(information: northEast), southWest: TileQueryRequest.Coordinate(information: southWest))

        if !forceLoad, let invalidationToken = invalidationTokenCache.invalidationToken(requestedArea: [area], for: zoomLevel) {
            area.invalidationToken = invalidationToken
        }

        let tileRequest = TileQueryRequest(areas: [area], zoomLevel: UInt32(zoomLevel))

        return loadPois(tileRequest) { result in
            switch result {
            case .failure(let error):
                handler(.failure(error))

            case .success(let poiResponse):
                let tilesResponse = poiResponse.tilesResponse
                let tiles = tilesResponse.tiles
                self.invalidationTokenCache.add(tiles: tiles, for: tilesResponse.zoomLevel)

                let stations = poiResponse.pois
                handler(.success(stations))
            }
        }
    }

    func fetchPOIs(locations: [CLLocation], handler: @escaping (Result<[POIKit.GasStation], Error>) -> Void) -> CancellablePOIAPIRequest? {
        let zoomLevel = POIKitConfig.minZoomLevelFullDetails
        let tiles = locations
            .map { $0.coordinate.tileCoordinate(withZoom: zoomLevel) }
            .map { TileQueryRequest.IndividualTileQuery(information: TileInformation(zoomLevel: zoomLevel, x: $0.x, y: $0.y), invalidationToken: nil) }

        let tileRequest = TileQueryRequest(tiles: tiles, zoomLevel: UInt32(zoomLevel))

        return loadPois(tileRequest) { result in
            switch result {
            case .failure(let error):
                handler(.failure(error))

            case .success(let poiResponse):
                // Parse gas stations and save to database
                let pois = poiResponse.pois
                self.save(pois)
                handler(.success(pois))
            }
        }
    }
}

// MARK: - Retrieving pois only with a database
extension POIKitAPI {
    func loadPOIs(boundingBox: POIKit.BoundingBox,
                  forceLoad: Bool = false,
                  handler: @escaping (Swift.Result<[POIKit.GasStation], Error>) -> Void) -> CancellablePOIAPIRequest? {
        let zoomLevel = POIKitConfig.minZoomLevelFullDetails
        let northEast = boundingBox.point1.tileInformation(forZoomLevel: zoomLevel)
        let southWest = boundingBox.point2.tileInformation(forZoomLevel: zoomLevel)
        var area = TileQueryRequest.AreaQuery(northEast: TileQueryRequest.Coordinate(information: northEast), southWest: TileQueryRequest.Coordinate(information: southWest))

        if !forceLoad, let invalidationToken = invalidationTokenCache.invalidationToken(requestedArea: [area], for: zoomLevel) {
            area.invalidationToken = invalidationToken
        }

        let tileRequest = TileQueryRequest(areas: [area], zoomLevel: UInt32(zoomLevel))

        return loadPois(tileRequest) { result in
            switch result {
            case .failure(let error):
                handler(.failure(error))

            case .success(let poiResponse):
                let tilesResponse = poiResponse.tilesResponse
                let tiles = tilesResponse.tiles

                self.invalidationTokenCache.add(tiles: tiles, for: tilesResponse.zoomLevel)

                // Save to database
                self.save(poiResponse.pois)

                let stations = POIKit.Database.shared.delegate?.get(inRect: boundingBox) ?? []
                handler(.success(stations))
            }
        }
    }

    func loadPOIs(uuids: [String],
                  handler: @escaping (Swift.Result<[POIKit.GasStation], Error>) -> Void) -> CancellablePOIAPIRequest? {
        let zoomLevel = POIKitConfig.minZoomLevelFullDetails
        let tiles = POIKit.Database.shared.delegate?
            .get(uuids: uuids)
            .compactMap { $0.coordinate?.tileCoordinate(withZoom: zoomLevel) }
            .map { TileQueryRequest.IndividualTileQuery(information: TileInformation(zoomLevel: zoomLevel, x: $0.x, y: $0.y), invalidationToken: nil) } ?? []

        let tileRequest = TileQueryRequest(tiles: tiles, zoomLevel: UInt32(zoomLevel))

        return loadPois(tileRequest) { result in
            switch result {
            case .failure(let error):
                handler(.failure(error))

            case .success(let poiResponse):
                // Parse gas stations and save to database
                self.save(poiResponse.pois)
                let gasStations = POIKit.Database.shared.delegate?.get(uuids: uuids) ?? []
                handler(.success(gasStations))
            }
        }
    }
}

extension POIKitAPI {
    func loadPois(_ tileRequest: TileQueryRequest,
                  completion: @escaping (Result<POIResponse, Error>) -> Void) -> CancellablePOIAPIRequest? {
        guard let tileRequestData = try? tileRequest.serializedData() else {
            completion(.failure(POIKit.POIKitAPIError.unknown))
            return nil
        }

        let dispatchGroup: DispatchGroup = .init()
        dispatchGroup.enter()
        dispatchGroup.enter()

        var cofuGasStations: [String: POIKit.CofuGasStation]?
        var tilesResponseResult: Result<TilesResponse, Error>?

        loadCoFuGasStations { cofuStations in
            // Due to constant lookup time convert array to dictionary here.
            // This is ultimatively faster than `contains(...)` when checking
            // if the pois are included in the geojson file in `extractPOIS(...)`
            cofuGasStations = cofuStations?.reduce(into: [:], { $0[$1.id] = $1 })
            dispatchGroup.leave()
        }

        let poiAPIRequest = loadTiles(tileRequestData) { result in
            tilesResponseResult = result
            dispatchGroup.leave()
        }

        dispatchGroup.notify(queue: cloudQueue) { [weak self] in
            guard let self = self, let tilesResponseResult = tilesResponseResult else {
                completion(.failure(POIKit.POIKitAPIError.unknown))
                return
            }

            switch tilesResponseResult {
            case .success(let tilesResponse):
                let pois = self.extractPOIS(from: tilesResponse.tiles, cofuGasStations: cofuGasStations)
                let poiResponse: POIResponse = .init(tilesResponse: tilesResponse, pois: pois)
                completion(.success(poiResponse))

            case .failure(let error):
                completion(.failure(error))
            }
        }

        return poiAPIRequest
    }

    private func loadTiles(_ tileRequestData: Data, // swiftlint:disable:this cyclomatic_complexity
                           completion: @escaping (Result<TilesResponse, Error>) -> Void) -> CancellablePOIAPIRequest? {
        let newRequest = POIAPI.Tiles.GetTiles.Request(body: tileRequestData)
        newRequest.version = ""

        return API.POI.client.makeRequest(newRequest, completionQueue: cloudQueue) { response in
            switch response.result {
            case .success(let data):
                guard let success = data.success, let tileResponse = try? TileQueryResponse(serializedData: success) else {
                    completion(.failure(POIKit.POIKitAPIError.serverError))
                    return
                }

                let timeToLive = self.timeToLive(from: response.urlResponse)
                let invalidationToken = tileResponse.invalidationToken

                let tiles = tileResponse.vectorTiles.map {  Tile(tileInformation: TileInformation(zoomLevel: Int(tileResponse.zoom), x: Int($0.geo.x), y: Int($0.geo.y)),
                                                                 type: .poi,
                                                                 invalidationToken: invalidationToken,
                                                                 data: $0.vectorTiles,
                                                                 timeToLive: timeToLive) }

                let tilesResponse: TilesResponse = .init(tiles: tiles, zoomLevel: Int(tileResponse.zoom))
                completion(.success(tilesResponse))

            case .failure(let apiError):
                switch apiError {
                case .networkError(let error):
                    if let error = error as NSError?, error.code == NSURLError.notConnectedToInternet.rawValue {
                        completion(.failure(POIKit.POIKitAPIError.networkError))
                    } else if (error as NSError?)?.code == NSURLErrorCancelled {
                        completion(.failure(POIKit.POIKitAPIError.operationCanceledByClient))
                    } else {
                        completion(.failure(error))
                    }

                case .requestEncodingError(let error),
                     .validationError(let error),
                     .unknownError(let error):
                    completion(.failure(error))

                case .decodingError(let error):
                    completion(.failure(error))

                case .unexpectedStatusCode(statusCode: let statusCode, data: _):
                    if statusCode == HttpStatusCode.rangeNotSatisfiable.rawValue {
                        completion(.failure(POIKit.POIKitAPIError.searchDiameterTooLarge))
                    } else {
                        completion(.failure(POIKit.POIKitAPIError.unknown))
                    }

                default:
                    completion(.failure(POIKit.POIKitAPIError.unknown))
                }
            }
        }
    }

    private func extractPOIS(from tiles: [Tile], cofuGasStations: [String: POIKit.CofuGasStation]?) -> [POIKit.GasStation] {
        var pois: [POIKit.GasStation] = []

        for tile in tiles {
            guard let poiTile = try? VectorTile_Tile(serializedData: tile.data) else { continue }
            pois.append(contentsOf: poiTile.loadPOIContents(for: tile.tileInformation))
        }

        guard let cofuGasStations = cofuGasStations else { return pois }

        // Add info if pois are part of the geojson file
        for poi in pois {
            guard let poiId = poi.id, let cofuGasStation = cofuGasStations[poiId] else { continue }
            poi.isOnlineCoFuGasStation = cofuGasStation.cofuStatus == .online
        }

        return pois
    }

    func save(_ pois: [POIKit.GasStation]) {
        // Add new POIs to database and update existing ones
        POIKit.Database.shared.delegate?.add(pois)
    }

    private func loadCoFuGasStations(completion: @escaping ([POIKit.CofuGasStation]?) -> Void) {
        POIKit.requestCofuGasStations(option: .all, completion: completion)
    }

    private func timeToLive(from response: HTTPURLResponse?) -> Int? {
        let cacheControlHeader = response?.allHeaderFields["Cache-Control"] as? String ?? ""
        let cacheControlComponents = cacheControlHeader.split(separator: "=")
        guard let index = cacheControlComponents.firstIndex(where: { $0 == "max-age" }),
            index + 1 < cacheControlComponents.count,
            let timeToLiveFromCache = Int(cacheControlComponents[index + 1]) else {
                return nil
        }
        return timeToLiveFromCache
    }
}
