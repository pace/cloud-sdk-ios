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
                   forceLoad: Bool = false,
                   handler: @escaping (Swift.Result<[POIKit.GasStation], Error>) -> Void) -> CancellablePOIAPIRequest? {
        guard let validatedBoundingBox = validateBoundingBoxDiameter(with: boundingBox) else {
            handler(.failure(POIKit.POIKitAPIError.searchDiameterTooLarge))
            return nil
        }

        let zoomLevel = POIKitConfig.maxZoomLevel
        let northEast = validatedBoundingBox.point1.tileInformation(forZoomLevel: zoomLevel)
        let southWest = validatedBoundingBox.point2.tileInformation(forZoomLevel: zoomLevel)
        var area = TileQueryRequest.AreaQuery(northEast: TileQueryRequest.Coordinate(information: northEast), southWest: TileQueryRequest.Coordinate(information: southWest))

        if !forceLoad, let invalidationToken = invalidationTokenCache.invalidationToken(requestedArea: [area], for: zoomLevel) {
            area.invalidationToken = invalidationToken
        }

        let tileRequest = TileQueryRequest(areas: [area], zoomLevel: UInt32(zoomLevel))

        return loadPois(tileRequest, boundingBox: validatedBoundingBox) { result in
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
                  forceLoad: Bool = false,
                  handler: @escaping (Swift.Result<[POIKit.GasStation], Error>) -> Void) -> CancellablePOIAPIRequest? {
        guard let validatedBoundingBox = validateBoundingBoxDiameter(with: boundingBox) else {
            handler(.failure(POIKit.POIKitAPIError.searchDiameterTooLarge))
            return nil
        }

        let zoomLevel = POIKitConfig.maxZoomLevel
        let northEast = validatedBoundingBox.point1.tileInformation(forZoomLevel: zoomLevel)
        let southWest = validatedBoundingBox.point2.tileInformation(forZoomLevel: zoomLevel)
        var area = TileQueryRequest.AreaQuery(northEast: TileQueryRequest.Coordinate(information: northEast), southWest: TileQueryRequest.Coordinate(information: southWest))

        if !forceLoad, let invalidationToken = invalidationTokenCache.invalidationToken(requestedArea: [area], for: zoomLevel) {
            area.invalidationToken = invalidationToken
        }

        let tileRequest = TileQueryRequest(areas: [area], zoomLevel: UInt32(zoomLevel))

        return loadPois(tileRequest, boundingBox: validatedBoundingBox) { result in
            switch result {
            case .failure(let error):
                handler(.failure(error))

            case .success(let tiles):
                // Save to database
                self.save(tiles, for: validatedBoundingBox)

                let stations = POIKit.Database.shared.delegate?.get(inRect: validatedBoundingBox) ?? []
                handler(.success(stations))
            }
        }
    }

    func loadPOIs(uuids: [String],
                  handler: @escaping (Swift.Result<[POIKit.GasStation], Error>) -> Void) -> CancellablePOIAPIRequest? {
        let zoomLevel = POIKitConfig.maxZoomLevel
        let tiles = POIKit.Database.shared.delegate?
            .get(uuids: uuids)
            .compactMap { $0.coordinate?.tileCoordinate(withZoom: zoomLevel) }
            .map { TileQueryRequest.IndividualTileQuery(information: TileInformation(zoomLevel: zoomLevel, x: $0.x, y: $0.y), invalidationToken: nil) } ?? []

        let tileRequest = TileQueryRequest(tiles: tiles, zoomLevel: UInt32(zoomLevel))

        return loadPois(tileRequest, boundingBox: nil) { result in
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

    func loadPOIs(locations: [CLLocation], handler: @escaping (Result<[POIKit.GasStation], Error>) -> Void) -> CancellablePOIAPIRequest? {
        let zoomLevel = POIKitConfig.maxZoomLevel
        let tiles = locations
            .map { $0.coordinate.tileCoordinate(withZoom: zoomLevel) }
            .map { TileQueryRequest.IndividualTileQuery(information: TileInformation(zoomLevel: zoomLevel, x: $0.x, y: $0.y), invalidationToken: nil) }

        let tileRequest = TileQueryRequest(tiles: tiles, zoomLevel: UInt32(zoomLevel))

        return loadPois(tileRequest, boundingBox: nil) { result in
            switch result {
            case .failure(let error):
                handler(.failure(error))

            case .success(let tiles):
                // Parse gas stations and save to database
                self.save(tiles)
                let stations = self.extractPOIS(from: tiles)
                handler(.success(stations))
            }
        }
    }

    func loadPois(_ tileRequest: TileQueryRequest, // swiftlint:disable:this cyclomatic_complexity function_body_length
                  boundingBox: POIKit.BoundingBox?,
                  completion: @escaping (Swift.Result<[Tile], Error>) -> Void) -> CancellablePOIAPIRequest? {
        guard let data = try? tileRequest.serializedData() else {
            completion(.failure(POIKit.POIKitAPIError.unknown))
            return nil
        }

        let newRequest = POIAPI.Tiles.GetTiles.Request(body: data)
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
                if boundingBox != nil {
                    // Only work with invalidation tokens if there is a bounding box involved
                    self.invalidationTokenCache.add(tiles: tiles, for: Int(tileResponse.zoom))
                }

                completion(.success(tiles))

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

        // Add new POIs to database and update existing ones
        POIKit.Database.shared.delegate?.add(pois)
    }

    func validateBoundingBoxDiameter(with boundingBox: POIKit.BoundingBox) -> POIKit.BoundingBox? {
        let maxPoiSearchBoxSize = POIKitConfig.maxPoiSearchBoxSize * 2
        let toleratedDiameter = maxPoiSearchBoxSize * 1.01

        guard boundingBox.diameter <= toleratedDiameter else {
            // Diameter too large. Bounding box cannot be used
            return nil
        }

        if (maxPoiSearchBoxSize...toleratedDiameter).contains(boundingBox.diameter) {
            // Diameter is within the tolerated range. Adjust bounding box to the nearly exact max allowed diameter
            let adjustedRadius = POIKitConfig.maxPoiSearchBoxSize * 0.998 // Decrease the radius a bit to match the allowed diameter -> 0.998 == diameter of ~39983
            let adjustedBoundingBox = POIKit.BoundingBox(center: boundingBox.center, radius: adjustedRadius, padding: boundingBox.padding)
            return adjustedBoundingBox
        }

        // Return bounding box as is. Nothing has to be adjusted
        return boundingBox
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
