//
//  GeoAPIManager.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import CoreLocation
import Foundation

/**
 This class is used to fetch and temporarily store a geojson response
 which contains every cofu gas station with its polygon and app information.

 For every `requestLocalApps()` triggered by the client it returns the currently
 available apps for the given location without sending a request every time.

 To reduce network requests and computation the caching is implemented as follows:
 - Fetch the geojson information with the initial `requestLocalApps()` call and decode the json
 - Build a cache object by only using the cofu stations that are within a specified radius
 - This cache object is valid for a predefined time to return apps
 - If the cache expires or the user's location isn't in the specified radius anymore -> Send new request
 - Additionally we use the native response caching of `URLSession` within the network layer
 */
class GeoAPIManager {
    var speedThreshold: Double = Constants.Configuration.defaultSpeedThreshold
    var geoAppsScope: String = PACECloudSDK.shared.config?.geoAppsScope ?? Constants.Configuration.defaultGeoAppsScope

    private let session: URLSession
    private let cloudQueue = DispatchQueue(label: "appkit-cloud-queue")
    private let apiVersion = "2021-1"

    private var sessionTask: URLSessionDataTask?

    private var cachedCofuFeatures: [GeoAPIFeature]?
    private var cacheCofuLastUpdatedAt: Date?

    private var cachedFeatures: [GeoAPIFeature]?
    private var cacheLastUpdatedAt: Date?
    private var cacheCenter: CLLocation?
    private let cacheMaxAge: TimeInterval = 60 * 60 // 1h
    private let cacheRadius: CLLocationDistance = 30_000 // 30km

    init() {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .useProtocolCachePolicy

        // https://pspdfkit.com/blog/2020/downloading-large-files-with-urlsession/
        // cache size must be at least 20x as big as the data that needes to be cached
        // the defined capacity will actually not be allocated but still needs to be defined as such
        let memoryCapacity = 200 * 1024 * 1024 // 200 MB
        let diskCapacity = 1 * 1024 * 1024 * 1024 // 1 GB
        let cachesURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
        let diskCachePath = cachesURL?.appendingPathComponent("GeoAppsResponseCache").absoluteString
        let cache = URLCache(memoryCapacity: memoryCapacity, diskCapacity: diskCapacity, diskPath: diskCachePath)
        configuration.urlCache = cache

        configuration.setCustomURLProtocolIfAvailable()

        self.session = URLSession(configuration: configuration)
    }

    func cofuGasStations(for location: CLLocation? = nil, result: @escaping (Result<[CofuGasStation], GeoApiManagerError>) -> Void) {
        if let location = location {
            cofuGasStations(for: location, result: result)
        } else {
            cofuGasStations(result: result)
        }
    }

    private func cofuGasStations(for location: CLLocation, result: @escaping (Result<[CofuGasStation], GeoApiManagerError>) -> Void) {
        // Speed accuracy is measured in m/s.
        // Negative value means the speed property is invalid,
        // we will therefore only consider the speed, if the
        // accuracy is anywhere between 0 and ~10km/h.
        if 0...3 ~= location.speedAccuracy && location.speed > speedThreshold {
            result(.failure(.invalidSpeed))
            return
        }

        guard let cachedFeatures = cachedFeatures, !isCacheOutdated(for: location) else {
            // Send request if cache is not available or outdated
            fetchCofuGasStations(for: location) { [weak self] response in
                guard let self = self else {
                    result(.failure(.unknownError))
                    return
                }

                switch response {
                case .success:
                    guard let cachedFeatures = self.cachedFeatures else { return }
                    self.loadCofuStations(with: cachedFeatures, for: location, result: result)

                case .failure(let error):
                    result(.failure(error))
                }
            }
            return
        }

        // Load cofu stations from cache
        loadCofuStations(with: cachedFeatures, for: location, result: result)
    }

    private func cofuGasStations(result: @escaping (Result<[CofuGasStation], GeoApiManagerError>) -> Void) {
        guard let cachedCofuFeatures = cachedFeatures, !isCacheOutdated() else {
            // Send request if cache is not available or outdated
            fetchCofuGasStations { [weak self] response in
                guard let self = self else {
                    result(.failure(.unknownError))
                    return
                }

                switch response {
                case .success:
                    guard let cachedCofuFeatures = self.cachedCofuFeatures else { return }
                    self.loadCofuStations(with: cachedCofuFeatures, result: result)

                case .failure(let error):
                    result(.failure(error))
                }
            }
            return
        }

        // Load cofu stations from cache
        loadCofuStations(with: cachedCofuFeatures, result: result)
    }

    func loadCofuStations(with features: [GeoAPIFeature], for location: CLLocation? = nil, result: @escaping (Result<[CofuGasStation], GeoApiManagerError>) -> Void) {
        cloudQueue.async {
            let cofuStations = self.retrieveCoFuGasStations(from: features)

            guard let location = location else {
                result(.success(cofuStations))
                return
            }

            let point = [location.coordinate.longitude, location.coordinate.latitude]
            let apps: [CofuGasStation] = cofuStations.filter { RayCasting.contains(shape: $0.polygon?.first ?? [], point: point) }

            result(.success(apps))
        }
    }

    func fetchCofuGasStations(for location: CLLocation? = nil, result: @escaping (Result<[CofuGasStation], GeoApiManagerError>) -> Void) {
        performGeoRequest { [weak self] apiResult in
            guard let unwrappedSelf = self else {
                result(.failure(.unknownError))
                return
            }

            switch apiResult {
            case .success(let apiResponse):
                guard let features = apiResponse?.features else {
                    // If request fails reset cache to try again next time
                    self?.resetCache()
                    result(.failure(.invalidResponse))
                    return
                }

                if let location = location {
                    let relevantFeatures = unwrappedSelf.filterRelevant(features, for: location)
                    unwrappedSelf.cachedFeatures = relevantFeatures
                    unwrappedSelf.cacheLastUpdatedAt = Date()
                    unwrappedSelf.cacheCenter = location
                    let cofuStations: [CofuGasStation] = unwrappedSelf.retrieveCoFuGasStations(from: relevantFeatures)
                    result(.success(cofuStations))
                } else {
                    unwrappedSelf.cachedCofuFeatures = features
                    unwrappedSelf.cacheCofuLastUpdatedAt = Date()
                    let cofuStations: [CofuGasStation] = unwrappedSelf.retrieveCoFuGasStations(from: features)
                    result(.success(cofuStations))
                }

            case .failure(let error):
                result(.failure(error))
            }
        }
    }

    func retrieveCoFuGasStations(from geoFeatures: [GeoAPIFeature]) -> [CofuGasStation] {
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
                        NSLog("[GeoAPIManager] unhandled nested GeometryCollectionsFeature")
                    }
                }
            }

            guard let id = feature.id,
                  let properties = feature.properties
            else {
                return nil
            }

            let newProperties = Dictionary(uniqueKeysWithValues: properties.map { key, value in (key, value.value) })

            return CofuGasStation(id: id, coordinates: pointValue, polygon: polygonValue, properties: newProperties)
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

            self.sessionTask?.cancel()
            self.sessionTask = self.session.dataTask(with: request, completionHandler: { [weak self] data, response, error -> Void in
                if let error = error {
                    if (error as NSError?)?.code == NSURLErrorCancelled {
                        result(.failure(.requestCancelled))
                        return
                    }

                    AppKitLogger.e("[GeoAPIManager] Failed fetching polygons with error \(error)")
                    result(.failure(.unknownError))
                    return
                }

                guard let response = response as? HTTPURLResponse else {
                    AppKitLogger.e("[GeoAPIManager] Failed fetching polygons due to invalid response")
                    result(.failure(.invalidResponse))
                    return
                }

                let statusCode = response.statusCode

                guard statusCode < 400 else {
                    AppKitLogger.e("[GeoAPIManager] Failed fetching polygons with status code \(statusCode)")
                    result(.failure(.unknownError))
                    return
                }

                guard let data = data else {
                    AppKitLogger.e("[GeoAPIManager] Failed fetching polygons due to invalid data")
                    result(.failure(.invalidResponse))
                    return
                }

                let decodedResponse = self?.decodeGeoAPIResponse(geoApiData: data)
                result(.success(decodedResponse))
            })

            self.sessionTask?.resume()
        }
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
            AppKitLogger.e("[GeoAPIManager] Failed decoding geo api response with error \(error)")
            return nil
        }
    }

    deinit {
        sessionTask?.cancel()
    }
}

// MARK: - Cache
private extension GeoAPIManager {
    private func isCacheOutdated(for location: CLLocation? = nil) -> Bool {
        if let location = location {
            return isCacheOutdated(with: location)
        } else {
            return isCofuCacheOutdated()
        }
    }

    private func isCofuCacheOutdated() -> Bool {
        guard let lastUpdated = cacheCofuLastUpdatedAt else { return true }
        return abs(lastUpdated.timeIntervalSinceNow) > cacheMaxAge
    }

    private func isCacheOutdated(with location: CLLocation) -> Bool {
        guard let lastUpdated = cacheLastUpdatedAt, let cacheCenter = cacheCenter else { return true }
        return abs(lastUpdated.timeIntervalSinceNow) > cacheMaxAge || cacheCenter.distance(from: location) > cacheRadius
    }

    func filterRelevant(_ features: [GeoAPIFeature], for location: CLLocation) -> [GeoAPIFeature] {
        let filteredResponse = features.filter { feature in
            guard let geometry = feature.geometry else { return false }
            return isInRadius(geometry: geometry, location: location)
        }

        return filteredResponse
    }

    func resetCache() {
        cacheLastUpdatedAt = nil
        cachedFeatures = nil
        cacheCenter = nil
    }
}

// MARK: - isPoiInRange
extension GeoAPIManager {
    func isPoiInRange(with id: String, near location: CLLocation, completion: @escaping (Bool) -> Void) {
        if 0...3 ~= location.speedAccuracy && location.speed > speedThreshold {
            completion(false)
            return
        }

        guard let cachedFeatures = cachedFeatures, !isCacheOutdated() else {
            // Send request if cache is not available or outdated
            fetchCofuGasStations { [weak self] response in
                guard let self = self else {
                    completion(false)
                    return
                }

                switch response {
                case .success(let fetchedStations):
                    var isAvailable = self.isAppAvailable(for: id, location: location, cofuStations: fetchedStations)
                    if !isAvailable,
                       let cachedFeatures = self.cachedFeatures {
                        isAvailable = self.isAppAvailable(for: id, location: location, features: cachedFeatures)
                    }
                    completion(isAvailable)

                case .failure:
                    completion(false)
                }
            }
            return
        }

        let stations = retrieveCoFuGasStations(from: cachedFeatures)

        var isAvailable = isAppAvailable(for: id, location: location, cofuStations: stations)
        if !isAvailable {
            isAvailable = isAppAvailable(for: id, location: location, features: cachedFeatures)
        }
        completion(isAvailable)
    }

    private func isInRadius(geometry: GeometryFeature, location: CLLocation) -> Bool {
        switch geometry {
        case .point(let pointFeature):
            return isInRadius(point: pointFeature, location: location)

        case .polygon(let polygonFeature):
            return isInRadius(polygon: polygonFeature, location: location)

        case .collections(let collectionFeature):
            return isInRadius(collection: collectionFeature, location: location)
        }
    }

    private func isInRadius(point: GeometryPointFeature, location: CLLocation) -> Bool {
        guard let lon = point.coordinates[safe: 0], let lat = point.coordinates[safe: 1] else { return false }
        let pointLocation = CLLocation(latitude: lat, longitude: lon)
        return location.distance(from: pointLocation) < cacheRadius
    }

    private func isInRadius(polygon: GeometryPolygonFeature, location: CLLocation) -> Bool {
        for coordinates in polygon.coordinates {
            for coordinate in coordinates {
                guard let lon = coordinate[safe: 0], let lat = coordinate[safe: 1] else { continue }
                let polygonEdgeLocation = CLLocation(latitude: lat, longitude: lon)

                if location.distance(from: polygonEdgeLocation) > cacheRadius {
                    return false
                }
            }
        }

        return true
    }

    private func isInRadius(collection: GeometryCollectionsFeature, location: CLLocation) -> Bool {
        guard let geometries = collection.geometries else { return false }

        for geometry in geometries {
            switch geometry {
            case .point(let point):
                return isInRadius(point: point, location: location)

            default:
                continue
            }
        }

        for geometry in geometries {
            return isInRadius(geometry: geometry, location: location)
        }

        return false
    }


    private func isAppAvailable(for id: String, location: CLLocation, cofuStations: [CofuGasStation]) -> Bool {
        guard let app = cofuStations.first(where: { $0.id == id }),
              let coordinates = app.coordinates,
              let lon = coordinates[safe: 0], let lat = coordinates[safe: 1] else { return false }

        return location.distance(from: CLLocation(latitude: lat, longitude: lon)) <= Constants.isPoiInRangeThreshold
    }

    private func isAppAvailable(for id: String, location: CLLocation, features: [GeoAPIFeature]) -> Bool {
        guard let app = features.first(where: { $0.id == id }) else { return false }

        switch app.geometry {
        case .polygon(let polygonFeature):
            return polygonFeature.coordinates.first?.contains(where: { coordinate in
                guard let lon = coordinate[safe: 0], let lat = coordinate[safe: 1] else { return false }
                let polygonEdgeLocation = CLLocation(latitude: lat, longitude: lon)
                return location.distance(from: polygonEdgeLocation) <= Constants.isPoiInRangeThreshold
            }) ?? false

        case .none, .point, .collections:
            return false
        }
    }
}
