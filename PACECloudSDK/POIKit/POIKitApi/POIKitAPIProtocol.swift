//
//  POIKitApiProtocol.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import CoreLocation
import Foundation

protocol POIKitAPIProtocol {
    var environment: PACECloudSDK.Environment { get set }
    func setLanguage(_ language: String)

    func observe(poisOfType: POIKit.POILayer, // swiftlint:disable:this function_parameter_count
                 boundingBox: POIKit.BoundingBox,
                 maxDistance: (distance: Double, padding: Double)?,
                 zoomLevel: Int?,
                 forceLoad: Bool,
                 handler: @escaping (Bool, Result<[POIKit.GasStation], Error>) -> Void) -> POIKit.BoundingBoxNotificationToken

    func regionalPrice(_ request: RegionalPriceRequest, result: @escaping (Result<POIKit.RegionalPricesResponse, Error>) -> Void)

    func priceHistory<T: AnyPriceHistoryResponse>(_ request: POIKit.PriceHistoryRequest<T>, result: @escaping (Result<T, Error>) -> Void)

    func gasStation(_ request: GasStationRequest, result: @escaping (Result<POIKit.GasStationResponse, Error>) -> Void)

    func gasStations(_ requests: [GasStationRequest], result: @escaping (Result<[POIKit.GasStation], Error>) -> Void)

    func fetchPOIs(boundingBox: POIKit.BoundingBox,
                   forceLoad: Bool,
                   handler: @escaping (Result<[POIKit.GasStation], Error>) -> Void) -> CancellablePOIAPIRequest?

    func fetchPOIs(locations: [CLLocation],
                   handler: @escaping (Result<[POIKit.GasStation], Error>) -> Void) -> CancellablePOIAPIRequest?
}
