//
//  POIKitApiProtocol.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

protocol POIKitAPIProtocol {
    var environment: PACECloudSDK.Environment { get set }
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

    func route(_ request: POIKit.NavigationRequest, handler: ((POIKit.NavigationResponse?, POIKit.POIKitAPIError) -> Void)?)

    func regionalPrice(_ request: RegionalPriceRequest, result: @escaping (Result<POIKit.RegionalPricesResponse, Error>) -> Void)

    func filters(_ request: POIFiltersRequest, result: @escaping (Result<POIFiltersResponse, Error>) -> Void)

    func priceHistory(_ request: PriceHistoryRequest, result: @escaping (Result<PCPriceHistory, Error>) -> Void)

    func gasStation(_ request: GasStationRequest, result: @escaping (Result<POIKit.GasStationResponse, Error>) -> Void)

    func fetchPOIs(poisOfType: POIKit.POILayer,
                   boundingBox: POIKit.BoundingBox,
                   handler: @escaping (Result<[POIKit.GasStation], Error>) -> Void) -> URLSessionTask?

    func loadPOIs(poisOfType: POIKit.POILayer,
                  boundingBox: POIKit.BoundingBox,
                  handler: @escaping (Result<[POIKit.GasStation], Error>) -> Void) -> URLSessionTask?

    func loadPOIs(uuids: [String],
                  handler: @escaping (Result<[POIKit.GasStation], Error>) -> Void) -> URLSessionTask?
}
