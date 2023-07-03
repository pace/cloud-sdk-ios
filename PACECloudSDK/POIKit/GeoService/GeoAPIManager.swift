//
//  GeoAPIManager.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import CoreLocation
import Foundation

// swiftlint:disable type_body_length file_length

/**
 This class is used to fetch and temporarily store a geojson response
 which contains every cofu gas station with its polygon and app information.

 To reduce network requests and computation the caching is implemented as follows:
 - Fetch the geojson information with the initial call and decode the json
 - Build a cache object by only using the cofu stations that are within a specified radius
 - This cache object is valid for a predefined time to return apps
 - If the cache expires or the user's location isn't in the specified radius anymore -> Send new request
 - Additionally we use the native response caching of `URLSession` within the network layer
 */
class GeoAPIManager {
    var speedThreshold: Double = Constants.Configuration.defaultSpeedThreshold
    var geoAppsScope: String = PACECloudSDK.shared.config?.geoAppsScope ?? Constants.Configuration.defaultGeoAppsScope

    private let session: URLSession
    private let cloudQueue = DispatchQueue(label: "poikit-cloud-queue")
    private let apiVersion = "2021-1"

    private var sessionTask: URLSessionDataTask?

    private var allCofuFeatures: [GeoAPIFeature]?
    private var allCofuLastUpdatedAt: Date?

    private var locationBasedFeatures: [GeoAPIFeature]?
    private var locationBasedLastUpdatedAt: Date?

    private var cacheCenter: CLLocation?
    private let cacheMaxAge: TimeInterval = 60 * 60 // 1h
    private let cacheRadius: CLLocationDistance = 30_000 // 30km

    private var isGeoRequestRunning: Bool = false
    private var resultHandlers: [(Result<GeoAPIResponse?, GeoApiManagerError>) -> Void] = []

    init() {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .useProtocolCachePolicy

        // https://pspdfkit.com/blog/2020/downloading-large-files-with-urlsession/
        // cache size must be at least 20x as big as the data that needes to be cached
        // the defined capacity will actually not be allocated but still needs to be defined as such.
        let memoryCapacity = 200 * 1024 * 1024 // 200 MB
        let diskCapacity = 1 * 1024 * 1024 * 1024 // 1 GB
        let cachesURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
        let diskCachePath = cachesURL?.appendingPathComponent("GeoAppsResponseCache").absoluteString
        let cache = URLCache(memoryCapacity: memoryCapacity, diskCapacity: diskCapacity, diskPath: diskCachePath)
        configuration.urlCache = cache

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

        guard let cachedFeatures = locationBasedFeatures, !isLocationBasedCacheOutdated(with: location) else {
            // Send request if cache is not available or outdated
            fetchCofuGasStations(for: location) { [weak self] response in
                guard let self = self else {
                    result(.failure(.unknownError))
                    return
                }

                switch response {
                case .success(let cofuFeatures):
                    self.loadLocationBasedCofuStations(with: cofuFeatures, location: location, result: result)

                case .failure(let error):
                    result(.failure(error))
                }
            }
            return
        }

        // Load cofu stations from cache
        loadLocationBasedCofuStations(with: cachedFeatures, location: location, result: result)
    }

    // Load all available cofu stations with certain options
    func cofuGasStations(option: POIKit.CofuGasStation.Option, result: @escaping (Result<[POIKit.CofuGasStation], GeoApiManagerError>) -> Void) {
        guard let cachedCofuFeatures = allCofuFeatures, !isCofuCacheOutdated() else {
            // Send request if cache is not available or outdated
            fetchCofuGasStations(for: nil) { [weak self] response in
                guard let self = self else {
                    result(.failure(.unknownError))
                    return
                }

                switch response {
                case .success(let cofuFeatures):
                    self.loadAllCofuStations(with: cofuFeatures, option: option, result: result)

                case .failure(let error):
                    result(.failure(error))
                }
            }
            return
        }

        // Load cofu stations from cache
        loadAllCofuStations(with: cachedCofuFeatures, option: option, result: result)
    }

    private func loadLocationBasedCofuStations(with features: [GeoAPIFeature],
                                               location: CLLocation,
                                               result: @escaping (Result<[POIKit.CofuGasStation], GeoApiManagerError>) -> Void) {
        cloudQueue.async { [weak self] in
            guard let self = self else { return }
            let cofuStations = self.retrieveCoFuGasStations(from: features)

            let apps: [POIKit.CofuGasStation] = cofuStations.filter { station in
                if let coordinates = station.coordinates,
                   let lat = coordinates[safe: 1],
                   let lon = coordinates[safe: 0] {
                    let cofuStationLocation = CLLocation(latitude: lat, longitude: lon)
                    return self.isUserInLocationBasedCofuStationRange(cofuStationLocation: cofuStationLocation, userLocation: location)
                } else {
                    let coordinates = station.polygon?.flatMap { $0 } ?? []
                    return coordinates.contains(where: { coordinates in
                        guard let lat = coordinates[safe: 1], let lon = coordinates[safe: 0] else { return false }
                        let cofuStationLocation = CLLocation(latitude: lat, longitude: lon)
                        return self.isUserInLocationBasedCofuStationRange(cofuStationLocation: cofuStationLocation, userLocation: location)
                    })
                }
            }

            result(.success(apps))
        }
    }

    private func isUserInLocationBasedCofuStationRange(cofuStationLocation: CLLocation, userLocation: CLLocation) -> Bool {
        let locationOffset = PACECloudSDK.shared.config?.allowedAppDrawerLocationOffset ?? Constants.Configuration.defaultAllowedAppDrawerLocationOffset
        return cofuStationLocation.distance(from: userLocation) <= locationOffset
    }

    private func loadAllCofuStations(with features: [GeoAPIFeature],
                                     option: POIKit.CofuGasStation.Option,
                                     result: @escaping (Result<[POIKit.CofuGasStation], GeoApiManagerError>) -> Void) {
        cloudQueue.async {
            var cofuStations: [POIKit.CofuGasStation] = []

            if case let .boundingBox(center, radius) = option {
                let filteredFeatures = self.applyRadiusFilter(features, for: center, radius: radius)
                cofuStations = self.retrieveCoFuGasStations(from: filteredFeatures)
            } else if case .all = option {
                cofuStations = self.retrieveCoFuGasStations(from: features)
            }

            result(.success(cofuStations))
        }
    }

    private func fetchCofuGasStations(for location: CLLocation?, result: @escaping (Result<[GeoAPIFeature], GeoApiManagerError>) -> Void) {
        performGeoRequest { [weak self] apiResult in
            guard let self = self else {
                result(.failure(.unknownError))
                return
            }

            switch apiResult {
            case .success(let apiResponse):
                guard let features = apiResponse?.features else {
                    // If request fails reset cache to try again next time
                    self.resetCache()
                    result(.failure(.invalidResponse))
                    return
                }

                if let location = location {
                    let filteredFeatures = self.applyRadiusFilter(features, for: location, radius: self.cacheRadius)
                    self.locationBasedFeatures = filteredFeatures
                    self.locationBasedLastUpdatedAt = Date()
                    self.cacheCenter = location
                    result(.success(filteredFeatures))
                } else {
                    self.allCofuFeatures = features
                    self.allCofuLastUpdatedAt = Date()
                    result(.success(features))
                }

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

            let newProperties = Dictionary(uniqueKeysWithValues: properties.map { key, value in (key, value.value) })

            return POIKit.CofuGasStation(id: id, coordinates: pointValue, polygon: polygonValue, properties: newProperties)
        })
    }

    private func performGeoRequest(result: @escaping (Result<GeoAPIResponse?, GeoApiManagerError>) -> Void) {
        let baseUrl = Settings.shared.geoApiHostUrl
        guard let url = URL(string: "\(baseUrl)/\(apiVersion)/apps/\(geoAppsScope).geojson"),
              let urlWithQueryParams = QueryParamHandler.buildUrl(for: url) else {
            result(.failure(.unknownError))
            return
        }

        let request = URLRequest(url: urlWithQueryParams, withTracingId: true)

        cloudQueue.async { [weak self] in
            guard let self = self else {
                result(.failure(.unknownError))
                return
            }

            self.resultHandlers.append(result)

            guard !self.isGeoRequestRunning else { return }

            self.isGeoRequestRunning = true
            self.sessionTask?.cancel()
            self.sessionTask = self.session.dataTask(with: request, completionHandler: { [weak self] data, response, error -> Void in
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

                let decodedResponse = self?.decodeGeoAPIResponse(geoApiData: data)
                self?.notifyResultHandlers(with: .success(decodedResponse))
            })

            self.sessionTask?.resume()
        }
    }

    private func notifyResultHandlers(with result: Result<GeoAPIResponse?, GeoApiManagerError>) {
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

    private func retrievePolygon(from feature: GeoAPIFeature) -> [[[Double]]]? {
        switch feature.geometry {
        case .collections(let collection):
            return retrievePolygon(from: collection)

        case .polygon(let polygon):
            return polygon.coordinates

        case .point, .none:
            return nil
        }
    }

    private func retrievePolygon(from collection: GeometryCollectionsFeature) -> [[[Double]]]? {
        guard let geometries = collection.geometries else { return nil }
        for geometry in geometries {
            switch geometry {
            case .collections(let collection):
                return retrievePolygon(from: collection)

            case .polygon(let polygon):
                return polygon.coordinates

            default:
                break
            }
        }

        return nil
    }

    private func decodeGeoAPIResponse(geoApiData: Data) -> GeoAPIResponse? {
        do {
            let response = try JSONDecoder().decode(GeoAPIResponse.self, from: geoApiData)
            return response
        } catch {
            POIKitLogger.e("[GeoAPIManager] Failed decoding geo api response with error \(error)")
            return nil
        }
    }

    deinit {
        sessionTask?.cancel()
    }
}

// MARK: - Cache
private extension GeoAPIManager {
    func isCofuCacheOutdated() -> Bool {
        guard let lastUpdated = allCofuLastUpdatedAt else { return true }
        return abs(lastUpdated.timeIntervalSinceNow) > cacheMaxAge
    }

    func isLocationBasedCacheOutdated(with location: CLLocation) -> Bool {
        guard let lastUpdated = locationBasedLastUpdatedAt, let cacheCenter = cacheCenter else { return true }
        return abs(lastUpdated.timeIntervalSinceNow) > cacheMaxAge || cacheCenter.distance(from: location) > cacheRadius
    }

    func applyRadiusFilter(_ features: [GeoAPIFeature], for location: CLLocation, radius: CLLocationDistance) -> [GeoAPIFeature] {
        let filteredResponse = features.filter { feature in
            guard let geometry = feature.geometry else { return false }
            return isInRadius(geometry: geometry, location: location, radius: radius)
        }

        return filteredResponse
    }

    func resetCache() {
        locationBasedLastUpdatedAt = nil
        locationBasedFeatures = nil
        cacheCenter = nil

        allCofuLastUpdatedAt = nil
        allCofuFeatures = nil
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
}

// MARK: - isPoiInRange
extension GeoAPIManager {
    func isPoiInRange(with id: String, near location: CLLocation, completion: @escaping (Bool) -> Void) {
        if isSpeedThresholdExceeded(for: location) {
            completion(false)
            return
        }

        guard let cachedFeatures = locationBasedFeatures, !isLocationBasedCacheOutdated(with: location) else {
            // Send request if cache is not available or outdated
            fetchCofuGasStations(for: location) { [weak self] response in
                guard let self = self else {
                    completion(false)
                    return
                }

                switch response {
                case .success(let fetchedFeatures):
                    let cofuStations: [POIKit.CofuGasStation] = self.retrieveCoFuGasStations(from: fetchedFeatures)
                    let isAvailable = self.isAppAvailable(for: id, location: location, cofuStations: cofuStations)
                    completion(isAvailable)

                case .failure:
                    completion(false)
                }
            }
            return
        }

        let stations = retrieveCoFuGasStations(from: cachedFeatures)
        let isAvailable = isAppAvailable(for: id, location: location, cofuStations: stations)
        completion(isAvailable)
    }

    private func isAppAvailable(for id: String, location: CLLocation, cofuStations: [POIKit.CofuGasStation]) -> Bool {
        guard let app = cofuStations.first(where: { $0.id == id }),
              let distance = app.distance(from: location) else { return false }

        return distance <= Constants.isPoiInRangeThreshold
    }
}
