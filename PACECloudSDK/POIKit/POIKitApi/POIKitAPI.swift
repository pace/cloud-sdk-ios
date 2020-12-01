//
//  POIKitAPI.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import CoreLocation
import Foundation

protocol POIKitAPIProtocol {
    var environment: POIKit.POIKitEnvironment { get set }
    func setLanguage(_ language: String)

    func search(_ request: POIKit.AddressSearchRequest, handler: ((POIKit.GeoJSONResult?, POIKit.POIKitAPIError) -> Void)?)
    func autocomplete(_ request: POIKit.AddressSearchRequest, isThrottled: Bool, handler: ((POIKit.GeoJSONResult?, POIKit.POIKitAPIError) -> Void)?)

    func reverseGeocode(_ request: POIKit.ReverseGeocodeRequest, handler: ((POIKit.GeoJSONResult?, POIKit.POIKitAPIError) -> Void)?)

    func observe(delegate: POIKitObserverTokenDelegate,
                 poisOfType: POIKit.POILayer,
                 boundingBox: POIKit.BoundingBox,
                 maxDistance: (distance: Double, padding: Double)?,
                 handler: @escaping (Bool, Result<[POIKit.GasStation], Error>) -> Void) -> POIKit.BoundingBoxNotificationToken
    func observe(delegate: POIKitObserverTokenDelegate,
                 uuids: [String],
                 handler: @escaping (Bool, Result<[POIKit.GasStation], Error>) -> Void) -> POIKit.UUIDNotificationToken

    func fetchPOIs(poisOfType: POIKit.POILayer,
                   boundingBox: POIKit.BoundingBox,
                   handler: @escaping (Result<[POIKit.GasStation], Error>) -> Void) -> URLSessionTask?

    func loadPOIs(poisOfType: POIKit.POILayer,
                  boundingBox: POIKit.BoundingBox,
                  handler: @escaping (Result<[POIKit.GasStation], Error>) -> Void) -> URLSessionTask?

    func loadPOIs(uuids: [String],
                  handler: @escaping (Result<[POIKit.GasStation], Error>) -> Void) -> URLSessionTask?

    func route(_ request: POIKit.NavigationRequest, handler: ((POIKit.NavigationResponse?, POIKit.POIKitAPIError) -> Void)?)

    func regionalPrice(_ request: RegionalPriceRequest, result: @escaping (Result<POIKit.RegionalPricesResponse, Error>) -> Void)

    func filters(_ request: POIFiltersRequest, result: @escaping (Result<POIFiltersResponse, Error>) -> Void)

    func priceHistory(_ request: PriceHistoryRequest, result: @escaping (Result<PCPriceHistory, Error>) -> Void)

    func gasStation(_ request: GasStationRequest, result: @escaping (Result<POIKit.GasStationResponse, Error>) -> Void)
}

class POIKitAPI: POIKitAPIProtocol {
    var environment = POIKit.POIKitEnvironment.DEVELOPMENT {
        didSet {
            request.client.baseURL = environment.baseUrl(.api)
        }
    }
    let request: HttpRequestProtocol

    static let shared = POIKitAPI()

    // MARK: - Initialize

    init(request: HttpRequestProtocol = HttpRequest()) {
        self.request = request
    }

    func setLanguage(_ language: String) {
        request.set(language: language)
    }

    // MARK: - Internal methods

    func buildURL(_ baseUrl: POIKitBaseUrl, path: String, urlParams: [String: [String]] = [:]) -> URL? {
        var urlString = ""

        if !urlParams.isEmpty {
            urlString = "?"
            // Append each parameter to the url
            for (key, values) in urlParams {
                for value in values {
                    guard let key = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                        let value = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { continue }

                    if urlString.count > 1 { urlString += "&" }
                    urlString += "\(key)=\(value)"
                }
            }
        }

        // Prepend base url and path
        urlString = environment.baseUrl(baseUrl) + path + urlString

        return URL(string: urlString)
    }
}
