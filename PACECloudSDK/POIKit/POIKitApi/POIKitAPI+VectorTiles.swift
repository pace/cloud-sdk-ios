//
//  PKMapsAPI+VectorTiles.swift
//  PACEMapKit
//
//  Created by PACE Telematics GmbH.
//

import CoreLocation
import UIKit

extension POIKitAPI {
    func fetchPOIs(poisOfType: POIKit.POILayer,
                   boundingBox: POIKit.BoundingBox,
                   handler: @escaping (Swift.Result<[POIKit.GasStation], Error>) -> Void) -> URLSessionTask? {
        let zoomLevel = POIKitConfig.maxZoomLevel
        let northEast = boundingBox.point1.tileInformation(forZoomLevel: zoomLevel)
        let southWest = boundingBox.point2.tileInformation(forZoomLevel: zoomLevel)
        let tileRequest = TileQueryRequest(areas: [TileQueryRequest.AreaQuery(northEast: TileQueryRequest.Coordinate(information: northEast),
                                                                              southWest: TileQueryRequest.Coordinate(information: southWest),
                                                                              invalidationToken: nil)], zoomLevel: UInt32(zoomLevel))

        return loadPois(tileRequest) { result in
            switch result {
            case .failure(let error):
                handler(.failure(error))

            case .success(let tiles):
                let stations = self.extractPOIS(from: tiles)
                handler(.success(stations))
            }
        }
    }

    func loadPOIs(poisOfType: POIKit.POILayer,
                  boundingBox: POIKit.BoundingBox,
                  handler: @escaping (Swift.Result<[POIKit.GasStation], Error>) -> Void) -> URLSessionTask? {
        let zoomLevel = POIKitConfig.maxZoomLevel
        let northEast = boundingBox.point1.tileInformation(forZoomLevel: zoomLevel)
        let southWest = boundingBox.point2.tileInformation(forZoomLevel: zoomLevel)
        let tileRequest = TileQueryRequest(areas: [TileQueryRequest.AreaQuery(northEast: TileQueryRequest.Coordinate(information: northEast),
                                                                              southWest: TileQueryRequest.Coordinate(information: southWest),
                                                                              invalidationToken: nil)], zoomLevel: UInt32(zoomLevel))

        return loadPois(tileRequest) { result in
            switch result {
            case .failure(let error):
                handler(.failure(error))

            case .success(let tiles):
                // Save to database
                self.save(tiles, for: boundingBox)

                let stations = POIKit.Database.shared.delegate?.get(inRect: boundingBox) ?? []
                handler(.success(stations))
            }
        }
    }

    func loadPOIs(uuids: [String],
                  handler: @escaping (Swift.Result<[POIKit.GasStation], Error>) -> Void) -> URLSessionTask? {
        let zoomLevel = POIKitConfig.maxZoomLevel
        let tiles = POIKit.Database.shared.delegate?
            .get(uuids: uuids)
            .compactMap { $0.coordinate?.tileCoordinate(withZoom: zoomLevel) }
            .map { TileQueryRequest.IndividualTileQuery(information: TileInformation(zoomLevel: zoomLevel, x: $0.x, y: $0.y), invalidationToken: nil) } ?? []

        let tileRequest = TileQueryRequest(tiles: tiles, zoomLevel: UInt32(zoomLevel))

        return loadPois(tileRequest) { result in
            switch result {
            case .failure(let error):
                handler(.failure(error))

            case .success(let tiles):
                // Parse gas stations and save to database
                self.save(tiles)
                let gasStations = POIKit.Database.shared.delegate?.get(uuids: uuids) ?? []
                handler(.success(gasStations))
            }
        }
    }

    func loadPois(_ tileRequest: TileQueryRequest, completion: @escaping (Swift.Result<[Tile], Error>) -> Void) -> URLSessionTask? {
        guard let url = buildURL(.tilesApi, path: "/query"), let data = try? tileRequest.serializedData() else {
            completion(.failure(POIKit.POIKitAPIError.unknown))
                return nil
        }

        return request.httpRequest(.post, url: url, body: data, includeDefaultHeaders: false, headers: ["Content-Type": "application/protobuf"]) { response, data, error in
            if let error = error as NSError?, error.code == NSURLError.notConnectedToInternet.rawValue {
                completion(.failure(POIKit.POIKitAPIError.networkError))

                return
            }

            guard response?.statusCode == 200, let data = data, let tileResponse = try? TileQueryResponse(serializedData: data) else {
                if (error as NSError?)?.code == NSURLErrorCancelled {
                    completion(.failure(POIKit.POIKitAPIError.operationCanceledByClient))
                    return
                }

                completion(.failure(POIKit.POIKitAPIError.serverError))
                return
            }

            let timeToLive = self.timeToLive(from: response)

            let tiles = tileResponse.vectorTiles.map {  Tile(tileInformation: TileInformation(zoomLevel: Int(tileResponse.zoom), x: Int($0.geo.x), y: Int($0.geo.y)),
                                                             type: .poi,
                                                             invalidationToken: Int64(tileResponse.invalidationToken),
                                                             data: $0.vectorTiles,
                                                             timeToLive: timeToLive) }

            completion(.success(tiles))
        }
    }

    func extractPOIS(from tiles: [Tile]) -> [POIKit.GasStation] {
        var pois: [POIKit.GasStation] = []

        for tile in tiles {
            guard let poiTile = try? VectorTile_Tile(serializedData: tile.data) else { continue }

            pois.append(contentsOf: poiTile.loadPOIContents(for: tile.tileInformation))
        }

        return pois
    }

    func save(_ tiles: [Tile], for boundingBox: POIKit.BoundingBox? = nil) {
        let pois = extractPOIS(from: tiles)

        if let boundingBox = boundingBox {
            POIKit.Database.shared.delegate?.delete(ignoreIds: pois.compactMap { $0.id }, boundingBox: boundingBox)
        }

        // Add new POIs to database and update existing ones
        POIKit.Database.shared.delegate?.add(pois)
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
