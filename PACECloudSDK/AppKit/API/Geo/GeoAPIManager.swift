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
    var geoAppsScope: String = Constants.Configuration.defaultGeoAppsScope

    private let session: URLSession
    private let cloudQueue = DispatchQueue(label: "appkit-cloud-queue")
    private let apiVersion = "2021-1"

    private var sessionTask: URLSessionDataTask?

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

        self.session = URLSession(configuration: configuration)
    }

    func apps(for location: CLLocation, result: @escaping (Result<[GeoGasStation], GeoApiManagerError>) -> Void) {
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
            fetchPolygons(for: location, result: result)
            return
        }

        // Load apps from cache
        loadApps(for: location, with: cachedFeatures, result: result)
    }

    private func fetchPolygons(for location: CLLocation, result: @escaping (Result<[GeoGasStation], GeoApiManagerError>) -> Void) {
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

                let cachedFeatures = unwrappedSelf.buildCachedGeoAPIResponse(with: features, for: location)
                unwrappedSelf.cachedFeatures = cachedFeatures
                unwrappedSelf.loadApps(for: location, with: cachedFeatures, result: result)

            case .failure(let error):
                result(.failure(error))
            }
        }
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

                let decodedResponse = self?.decodeGeoAPIResonse(geoApiData: data)
                result(.success(decodedResponse))
            })

            self.sessionTask?.resume()
        }
    }

    private func loadApps(for location: CLLocation, with features: [GeoAPIFeature], result: @escaping ((Result<[GeoGasStation], GeoApiManagerError>) -> Void)) {
        let point = [location.coordinate.longitude, location.coordinate.latitude]

        cloudQueue.async {
            let apps: [GeoGasStation] = features.compactMap { feature in
                guard let id = feature.id, let apiCoordinates = feature.geometry?.coordinates else { return nil }

                let coordinates = apiCoordinates.flatMap { $0 }

                if RayCasting.contains(shape: coordinates, point: point) {
                    return .init(id: id, apps: feature.properties?.apps ?? [])
                }
                return nil
            }

            result(.success(apps))
        }
    }

    private func decodeGeoAPIResonse(geoApiData: Data) -> GeoAPIResponse? {
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
    func isCacheOutdated(for location: CLLocation) -> Bool {
        guard let lastUpdated = cacheLastUpdatedAt, let cacheCenter = cacheCenter else { return true }
        return abs(lastUpdated.timeIntervalSinceNow) > cacheMaxAge || cacheCenter.distance(from: location) > cacheRadius
    }

    func buildCachedGeoAPIResponse(with features: [GeoAPIFeature], for location: CLLocation) -> [GeoAPIFeature] {
        let filteredResponse = features.filter({ feature in
            guard let apiCoordinates = feature.geometry?.coordinates else { return false }
            let coordinates = apiCoordinates.flatMap { $0 }

            for coordinate in coordinates {
                guard let lon = coordinate[safe: 0], let lat = coordinate[safe: 1] else { continue }
                let polygonEdgeLocation = CLLocation(latitude: lat, longitude: lon)

                if location.distance(from: polygonEdgeLocation) > cacheRadius {
                    return false
                }
            }

            return true
        })

        cacheLastUpdatedAt = Date()
        cacheCenter = location

        return filteredResponse
    }

    func resetCache() {
        cacheLastUpdatedAt = nil
        cachedFeatures = nil
        cacheCenter = nil
    }
}
