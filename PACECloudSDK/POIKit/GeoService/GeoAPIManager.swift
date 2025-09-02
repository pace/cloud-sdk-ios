//
//  GeoAPIManager.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import CoreLocation
import Foundation
#if !PACECloudWatchSDK
internal import IkigaJSON
#endif

/**
 This class is used to fetch and store all geojson information
 which contains every cofu gas station with its location and app information.

 Network requests and memory footprint will be reduced as follows:
 - Use a SQLite database to persist the geo features to reduce in-memory footprint
 - Use a faster json decoder to improve decoding times and memory load
 - Use the native response caching of `URLSession` within the network layer + e-tags
 */
class GeoAPIManager {
    private let database: GeoDatabase
    private let speedThreshold: Double
    private let geoAppsScope: String

    private let session: URLSession
    private let apiVersion = "2021-1"

    private let lastFetchedInterval: TimeInterval = 60 * 60 // 1h
    private var lastFetchedAt: Date?

    private var isLastFetchedThresholdMet: Bool {
        guard let lastFetchedAt else { return true }
        return abs(lastFetchedAt.timeIntervalSinceNow) > lastFetchedInterval
    }

    init?(databaseUrl: URL, speedThreshold: Double, geoAppsScope: String) async {
        do {
            self.database = try await GeoDatabase(url: databaseUrl)
        } catch {
            POIKitLogger.e("[GeoAPIManager] Failed setting up geo database with error \(error)")
            return nil
        }

        self.speedThreshold = speedThreshold
        self.geoAppsScope = geoAppsScope

        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.setCustomURLProtocolIfAvailable()
        configuration.httpAdditionalHeaders = [HttpHeaderFields.userAgent.rawValue: Constants.userAgent]

        self.session = URLSession(configuration: configuration)
    }

    // Load cofu stations for a specific area; location based
    func locationBasedCofuStations(for location: CLLocation) async -> Result<[POIKit.CofuGasStation], GeoApiManagerError> {
        if isSpeedThresholdExceeded(for: location) {
            return .failure(.invalidSpeed)
        }

        let locationOffset = PACECloudSDK.shared.config?.allowedAppDrawerLocationOffset ?? Constants.Configuration.defaultAllowedAppDrawerLocationOffset
        return await loadCofuGasStations(option: .boundingCircle(center: location, radius: locationOffset))
    }

    // Load all available cofu stations with certain options
    func cofuGasStations(option: POIKit.CofuGasStation.Option) async -> Result<[POIKit.CofuGasStation], GeoApiManagerError> {
        await loadCofuGasStations(option: option)
    }

    private func loadCofuGasStations(option: POIKit.CofuGasStation.Option) async -> Result<[POIKit.CofuGasStation], GeoApiManagerError> {
        let result = await loadCofuGasStationsIntoDatabase()

        switch result {
        case .success:
            do {
                let cofuGasStations = switch option {
                case .all:
                    try await database.readAll()

                case .boundingBox(box: let boundingBox):
                    try await database.read(boundingBox: boundingBox)

                case .boundingCircle(center: let location, radius: let radius):
                    try await database.read(boundingBox: .init(center: location.coordinate, radius: radius))
                }

                return .success(cofuGasStations)
            } catch {
                resetLastFetchedDate()
                return .failure(.database(error))
            }

        case .failure(let error):
            return .failure(error)
        }
    }

    private func loadCofuGasStation(id: String) async -> Result<POIKit.CofuGasStation?, GeoApiManagerError> {
        let result = await loadCofuGasStationsIntoDatabase()

        switch result {
        case .success:
            do {
                let cofuGasStation = try await database.read(poiId: id)
                return .success(cofuGasStation)
            } catch {
                resetLastFetchedDate()
                return .failure(.database(error))
            }

        case .failure(let error):
            return .failure(error)
        }
    }

    private func loadCofuGasStationsIntoDatabase() async -> Result<Void, GeoApiManagerError> {
        let result = await fetchGeoAPIFeatures()

        switch result {
        case .success:
            return .success(())

        case .failure(let error):
            // For errors like `requestCancelled`, unexpected status codes >= 500 and network errors
            // cofu stations can still be loaded from database.
            // All other errors will be treated as such
            switch error {
            case .requestCancelled, .notModified, .lastFetchedThresholdNotMet:
                return .success(())

            case .network(let error as NSError):
                if error.code == NSURLErrorNotConnectedToInternet || error.code == NSURLErrorNetworkConnectionLost {
                    return .success(())
                } else {
                    return .failure(.network(error))
                }

            case .unexpectedStatusCode(statusCode: let statusCode):
                if statusCode >= HttpStatusCode.internalError.rawValue {
                    return .success(())
                } else {
                    return .failure(.unexpectedStatusCode(statusCode: statusCode))
                }

            default:
                return .failure(error)
            }
        }
    }

    private func fetchGeoAPIFeatures() async -> Result<Void, GeoApiManagerError> {
        let apiResult = await performGeoRequest()

        switch apiResult {
        case .success(let apiResponse):
            guard let features = apiResponse.features else {
                return .failure(.invalidResponse)
            }

            let result = await persistGeoAPIFeatures(features)
            return result

        case .failure(let error):
            return .failure(error)
        }
    }

    private func performGeoRequest() async -> Result<GeoAPIResponse, GeoApiManagerError> {
        guard isLastFetchedThresholdMet else { return .failure(.lastFetchedThresholdNotMet) }

        let baseUrl = Settings.shared.geoApiHostUrl

        guard let url = URL(string: "\(baseUrl)/\(apiVersion)/apps/\(geoAppsScope).geojson"),
              let urlWithQueryParams = PACECloudSDK.QueryParamUTMHandler.buildUrl(for: url) else {
            return .failure(.invalidURL)
        }

        var request = URLRequest(url: urlWithQueryParams, withTracingId: true)

        let eTag = await eTag()
        request.setValue(eTag, forHTTPHeaderField: HttpHeaderFields.ifNoneMatch.rawValue)

        do {
            let (data, urlResonse) = try await self.session.data(for: request)

            guard let response = urlResonse as? HTTPURLResponse else {
                POIKitLogger.e("[GeoAPIManager] Failed fetching features due to invalid response")
                return .failure(.invalidResponse)
            }

            let statusCode = response.statusCode

            guard statusCode < HttpStatusCode.badRequest.rawValue else {
                POIKitLogger.e("[GeoAPIManager] Failed fetching features with status code \(statusCode)")
                return .failure(.unexpectedStatusCode(statusCode: statusCode))
            }

            self.lastFetchedAt = Date()

            if statusCode == HttpStatusCode.notModified.rawValue {
                POIKitLogger.d("[GeoAPIManager] GeoJSON response not modified")
                return .failure(.notModified)
            }

            do {
                let decodedResponse = try decodedGeoAPIResponse(geoApiData: data)

                if let eTag = response.value(forHTTPHeaderField: HttpHeaderFields.etag.rawValue) {
                    await persistETag(eTag)
                }

                return .success(decodedResponse)
            } catch {
                POIKitLogger.e("[GeoAPIManager] Failed decoding features response with error \(error)")
                resetLastFetchedDate()
                return .failure(.decoding(error))
            }
        } catch {
            if (error as NSError?)?.code == NSURLErrorCancelled {
                return .failure(.requestCancelled)
            }

            POIKitLogger.e("[GeoAPIManager] Failed fetching features with error \(error)")
            return .failure(.network(error))
        }
    }

    private func persistGeoAPIFeatures(_ features: [GeoAPIFeature]) async -> Result<Void, GeoApiManagerError> {
        do {
            try await database.write(features)
            return .success(())
        } catch {
            POIKitLogger.e("[GeoAPIManager] Failed writing features to database with error \(error)")
            resetLastFetchedDate()
            return .failure(.database(error))
        }
    }

    private func isSpeedThresholdExceeded(for location: CLLocation) -> Bool {
        // Speed accuracy is measured in m/s.
        // Negative value means the speed property is invalid,
        // we will therefore only consider the speed, if the
        // accuracy is anywhere between 0 and ~10km/h.
        0...3 ~= location.speedAccuracy && location.speed > speedThreshold
    }

    private func decodedGeoAPIResponse(geoApiData: Data) throws -> GeoAPIResponse {
        #if PACECloudWatchSDK
        let response = try JSONDecoder().decode(GeoAPIResponse.self, from: geoApiData)
        #else
        let response = try IkigaJSONDecoder().decode(GeoAPIResponse.self, from: geoApiData)
        #endif

        return response
    }

    private func eTag() async -> String? {
        try? await database.readETag()
    }

    private func persistETag(_ eTag: String) async {
        try? await database.write(eTag)
    }

    private func resetLastFetchedDate() {
        self.lastFetchedAt = nil
    }
}

// MARK: - isPoiInRange
extension GeoAPIManager {
    func isPoiInRange(with id: String, near location: CLLocation) async -> Bool {
        if isSpeedThresholdExceeded(for: location) {
            return false
        }

        switch await loadCofuGasStation(id: id) {
        case .success(let cofuGasStation):
            guard let cofuGasStation else { return false }

            let isAvailable = self.isAppAvailable(cofuGasStation, at: location)
            return isAvailable

        case .failure:
            return false
        }
    }

    private func isAppAvailable(_ cofuStation: POIKit.CofuGasStation, at location: CLLocation) -> Bool {
        guard let distance = cofuStation.distance(from: location) else { return false }
        return distance <= Constants.isPoiInRangeThreshold
    }
}
