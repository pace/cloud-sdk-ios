//
//  GeoAPIManager.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import CoreLocation
import Foundation

// swiftlint:disable file_length

/**
 This class is used to fetch and temporarily store a geojson response
 which contains every cofu gas station with its polygon and app information.

 To reduce network requests and computation the caching is implemented as follows:
 - Fetch the geojson information with the initial call and cache raw Data
 - Parse filtered features on demand at the call site using a spatial filter
 - This cache is valid for a predefined TTL
 - If the cache expires -> Send new request
 - We disable the native caching of `URLSession` within the network layer, to save memory since the CDN etag changes every 15min even without changes
 */
class GeoAPIManager {
    var speedThreshold: Double = Constants.Configuration.defaultSpeedThreshold
    var geoAppsScope: String?

    private let session: URLSession
    private let cloudQueue = DispatchQueue(label: "poikit-cloud-queue")
    private let apiVersion = "2021-1"

    private var sessionTask: URLSessionDataTask?

    private var cachedGeoData: Data?
    private var geoDataLastUpdatedAt: Date?

    private let cacheMaxAge: TimeInterval = 60 * 60 // 1h
    private let cacheRadius: CLLocationDistance = 30_000 // 30km

    private var isGeoRequestRunning: Bool = false
    private var resultHandlers: [(Result<Data, GeoApiManagerError>) -> Void] = []

    init() {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.urlCache = nil

        configuration.setCustomURLProtocolIfAvailable()
        configuration.httpAdditionalHeaders = [HttpHeaderFields.userAgent.rawValue: Constants.userAgent]

        self.session = URLSession(configuration: configuration)
    }

    // Load cofu stations for a specific area; location based
    func locationBasedCofuStations(for location: CLLocation, result: @escaping (Result<[POIKit.CofuGasStation], GeoApiManagerError>) -> Void) {
        if isSpeedThresholdExceeded(for: location) {
            result(.failure(.invalidSpeed))
            return
        }

        ensureGeoDataCached { [weak self] cacheResult in
            guard let self = self else {
                result(.failure(.unknownError))
                return
            }

            switch cacheResult {
            case .success(let data):
                let filter: (GeometryFeature) -> Bool = {
                    self.isInRadius(geometry: $0, location: location, radius: self.cacheRadius)
                }
                let features = GeoJSONStreamParser.parseFeatures(from: data, filter: filter)
                let cofuStations = self.retrieveCoFuGasStations(from: features)
                let locationOffset = PACECloudSDK.shared.config?.allowedAppDrawerLocationOffset
                    ?? Constants.Configuration.defaultAllowedAppDrawerLocationOffset
                let apps: [POIKit.CofuGasStation] = cofuStations.filter { station in
                    if let coordinates = station.coordinates,
                       let lat = coordinates[safe: 1],
                       let lon = coordinates[safe: 0] {
                        let cofuStationLocation = CLLocation(latitude: lat, longitude: lon)
                        return cofuStationLocation.distance(from: location) <= locationOffset
                    } else {
                        let coordinates = station.polygon?.flatMap { $0 } ?? []
                        return coordinates.contains(where: { coordinates in
                            guard let lat = coordinates[safe: 1], let lon = coordinates[safe: 0] else { return false }
                            let cofuStationLocation = CLLocation(latitude: lat, longitude: lon)
                            return cofuStationLocation.distance(from: location) <= locationOffset
                        })
                    }
                }
                result(.success(apps))

            case .failure(let error):
                result(.failure(error))
            }
        }
    }

    // Load all available cofu stations with certain options
    func cofuGasStations(option: POIKit.CofuGasStation.Option, result: @escaping (Result<[POIKit.CofuGasStation], GeoApiManagerError>) -> Void) {
        ensureGeoDataCached { [weak self] cacheResult in
            guard let self = self else {
                result(.failure(.unknownError))
                return
            }

            switch cacheResult {
            case .success(let data):
                let filter: ((GeometryFeature) -> Bool)?
                switch option {
                case .all:
                    filter = nil

                case .boundingCircle(let center, let radius):
                    filter = { self.isInRadius(geometry: $0, location: center, radius: radius) }

                case .boundingBox(let box):
                    filter = { self.isInBoundingBox(geometry: $0, boundingBox: box) }
                }
                let features = GeoJSONStreamParser.parseFeatures(from: data, filter: filter)
                let stations = self.retrieveCoFuGasStations(from: features)
                result(.success(stations))

            case .failure(let error):
                result(.failure(error))
            }
        }
    }

    private func retrieveCoFuGasStations(from geoFeatures: [GeoAPIFeature]) -> [POIKit.CofuGasStation] {
        return (geoFeatures.compactMap { feature in
            var collectionFeature: GeometryCollectionsFeature?
            var pointValue: [Double]?
            var polygonValue: [[[Double]]]?

            switch feature.geometry {
            case .collections(let geoCollection):
                collectionFeature = geoCollection

            case .point(let pointFeature):
                pointValue = pointFeature.coordinates

            case .polygon(let polygonFeature):
                polygonValue = polygonFeature.coordinates

            case .none:
                return nil
            }

            if let collection = collectionFeature {
                collection.geometries?.forEach { geometry in
                    switch geometry {
                    case .point(let pointFeature):
                        pointValue = pointFeature.coordinates

                    case .polygon(let polygonFeature):
                        polygonValue = polygonFeature.coordinates

                    case .collections:
                        POIKitLogger.w("[GeoAPIManager] unhandled nested GeometryCollectionsFeature")
                    }
                }
            }

            guard let id = feature.id,
                  let properties = feature.properties
            else {
                return nil
            }

            return POIKit.CofuGasStation(id: id, coordinates: pointValue, polygon: polygonValue, properties: properties)
        })
    }

    // swiftlint:disable:next function_body_length
    private func ensureGeoDataCached(result: @escaping (Result<Data, GeoApiManagerError>) -> Void) {
        guard let geoAppsScope = geoAppsScope else {
            POIKitLogger.e("[GeoAPIManager] Value for `geoAppsScope` is missing.")
            result(.failure(.unknownError))
            return
        }

        let baseUrl = Settings.shared.geoApiHostUrl
        guard let url = URL(string: "\(baseUrl)/\(apiVersion)/apps/\(geoAppsScope).geojson"),
              let urlWithQueryParams = PACECloudSDK.QueryParamUTMHandler.buildUrl(for: url) else {
            result(.failure(.unknownError))
            return
        }

        let request = URLRequest(url: urlWithQueryParams, withTracingId: true)

        cloudQueue.async { [weak self] in
            guard let self = self else {
                result(.failure(.unknownError))
                return
            }

            if let data = self.cachedGeoData, !self.isGeoCacheOutdated() {
                result(.success(data))
                return
            }

            self.resultHandlers.append(result)

            guard !self.isGeoRequestRunning else { return }

            self.isGeoRequestRunning = true
            self.sessionTask?.cancel()
            self.sessionTask = self.session.dataTask(with: request, completionHandler: { [weak self] data, response, error in
                defer {
                    self?.isGeoRequestRunning = false
                }

                if let error = error {
                    if (error as NSError?)?.code == NSURLErrorCancelled {
                        self?.notifyResultHandlers(with: .failure(.requestCancelled))
                        return
                    }

                    POIKitLogger.e("[GeoAPIManager] Failed fetching polygons with error \(error)")
                    self?.notifyResultHandlers(with: .failure(.unknownError))
                    return
                }

                guard let response = response as? HTTPURLResponse else {
                    POIKitLogger.e("[GeoAPIManager] Failed fetching polygons due to invalid response")
                    self?.notifyResultHandlers(with: .failure(.invalidResponse))
                    return
                }

                let statusCode = response.statusCode

                guard statusCode < 400 else {
                    POIKitLogger.e("[GeoAPIManager] Failed fetching polygons with status code \(statusCode)")
                    self?.notifyResultHandlers(with: .failure(.unknownError))
                    return
                }

                guard let data = data else {
                    POIKitLogger.e("[GeoAPIManager] Failed fetching polygons due to invalid data")
                    self?.notifyResultHandlers(with: .failure(.invalidResponse))
                    return
                }

                self?.cachedGeoData = data
                self?.geoDataLastUpdatedAt = Date()
                self?.notifyResultHandlers(with: .success(data))
            })

            self.sessionTask?.resume()
        }
    }

    private func notifyResultHandlers(with result: Result<Data, GeoApiManagerError>) {
        resultHandlers.forEach { $0(result) }
        resultHandlers.removeAll()
    }

    private func isSpeedThresholdExceeded(for location: CLLocation) -> Bool {
        // Speed accuracy is measured in m/s.
        // Negative value means the speed property is invalid,
        // we will therefore only consider the speed, if the
        // accuracy is anywhere between 0 and ~10km/h.
        0...3 ~= location.speedAccuracy && location.speed > speedThreshold
    }

    deinit {
        sessionTask?.cancel()
    }
}

// MARK: - Cache
private extension GeoAPIManager {
    func isGeoCacheOutdated() -> Bool {
        guard let lastUpdated = geoDataLastUpdatedAt else { return true }
        return abs(lastUpdated.timeIntervalSinceNow) > cacheMaxAge
    }

    func resetCache() {
        cachedGeoData = nil
        geoDataLastUpdatedAt = nil
    }

    func isInBoundingBox(geometry: GeometryFeature, boundingBox: POIKit.BoundingBox) -> Bool {
        switch geometry {
        case .point(let pointFeature):
            return isInBoundingBox(point: pointFeature, boundingBox: boundingBox)

        case .polygon(let polygonFeature):
            return isInBoundingBox(polygon: polygonFeature, boundingBox: boundingBox)

        case .collections(let collectionFeature):
            return isInBoundingBox(collection: collectionFeature, boundingBox: boundingBox)
        }
    }

    func isInRadius(geometry: GeometryFeature, location: CLLocation, radius: CLLocationDistance) -> Bool {
        switch geometry {
        case .point(let pointFeature):
            return isInRadius(point: pointFeature, location: location, radius: radius)

        case .polygon(let polygonFeature):
            return isInRadius(polygon: polygonFeature, location: location, radius: radius)

        case .collections(let collectionFeature):
            return isInRadius(collection: collectionFeature, location: location, radius: radius)
        }
    }

    private func isInRadius(point: GeometryPointFeature, location: CLLocation, radius: CLLocationDistance) -> Bool {
        guard let lon = point.coordinates[safe: 0], let lat = point.coordinates[safe: 1] else { return false }
        let pointLocation = CLLocation(latitude: lat, longitude: lon)
        return location.distance(from: pointLocation) < radius
    }

    private func isInRadius(polygon: GeometryPolygonFeature, location: CLLocation, radius: CLLocationDistance) -> Bool {
        for coordinates in polygon.coordinates {
            for coordinate in coordinates {
                guard let lon = coordinate[safe: 0], let lat = coordinate[safe: 1] else { continue }
                let polygonEdgeLocation = CLLocation(latitude: lat, longitude: lon)

                if location.distance(from: polygonEdgeLocation) > radius {
                    return false
                }
            }
        }

        return true
    }

    private func isInRadius(collection: GeometryCollectionsFeature, location: CLLocation, radius: CLLocationDistance) -> Bool {
        guard let geometries = collection.geometries else { return false }

        for geometry in geometries {
            switch geometry {
            case .point(let point):
                return isInRadius(point: point, location: location, radius: radius)

            default:
                continue
            }
        }

        for geometry in geometries {
            return isInRadius(geometry: geometry, location: location, radius: radius)
        }

        return false
    }

    private func isInBoundingBox(point: GeometryPointFeature, boundingBox: POIKit.BoundingBox) -> Bool {
        guard let lon = point.coordinates[safe: 0], let lat = point.coordinates[safe: 1] else { return false }
        let pointCoordinates = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        return boundingBox.contains(coord: pointCoordinates)
    }

    private func isInBoundingBox(polygon: GeometryPolygonFeature, boundingBox: POIKit.BoundingBox) -> Bool {
        for coordinates in polygon.coordinates {
            for coordinate in coordinates {
                guard let lon = coordinate[safe: 0], let lat = coordinate[safe: 1] else { continue }
                let pointCoordinates = CLLocationCoordinate2D(latitude: lat, longitude: lon)

                if !boundingBox.contains(coord: pointCoordinates) {
                    return false
                }
            }
        }

        return true
    }

    private func isInBoundingBox(collection: GeometryCollectionsFeature, boundingBox: POIKit.BoundingBox) -> Bool {
        guard let geometries = collection.geometries else { return false }

        for geometry in geometries {
            switch geometry {
            case .point(let point):
                return isInBoundingBox(point: point, boundingBox: boundingBox)

            default:
                continue
            }
        }

        for geometry in geometries {
            return isInBoundingBox(geometry: geometry, boundingBox: boundingBox)
        }

        return false
    }
}

// MARK: - isPoiInRange
extension GeoAPIManager {
    func isPoiInRange(with id: String, near location: CLLocation, completion: @escaping (Bool) -> Void) {
        if isSpeedThresholdExceeded(for: location) {
            completion(false)
            return
        }

        ensureGeoDataCached { [weak self] cacheResult in
            guard let self = self, case .success(let data) = cacheResult else {
                completion(false)
                return
            }

            let filter: (GeometryFeature) -> Bool = {
                self.isInRadius(geometry: $0, location: location, radius: self.cacheRadius)
            }
            let features = GeoJSONStreamParser.parseFeatures(from: data, filter: filter)
            let cofuStations = self.retrieveCoFuGasStations(from: features)
            let isAvailable = self.isAppAvailable(for: id, location: location, cofuStations: cofuStations)
            completion(isAvailable)
        }
    }

    private func isAppAvailable(for id: String, location: CLLocation, cofuStations: [POIKit.CofuGasStation]) -> Bool {
        guard let app = cofuStations.first(where: { $0.id == id }),
              let distance = app.distance(from: location) else { return false }

        return distance <= Constants.isPoiInRangeThreshold
    }
}
