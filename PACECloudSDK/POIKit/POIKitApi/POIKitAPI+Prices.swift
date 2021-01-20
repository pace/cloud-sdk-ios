//
//  POIKitAPI+Prices.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import CoreLocation

// swiftlint:disable all
extension POIKitAPI {
    func regionalPrice(_ request: RegionalPriceRequest,
                       result: @escaping (Result<POIKit.RegionalPricesResponse, Error>) -> Void) {
        let apiRequest = POIAPI.Prices.GetRegionalPrices.Request(options: request.options)
        API.POI.client.makeRequest(apiRequest) { apiResult in
            switch apiResult.result {
            case .success(let response):
                guard response.statusCode == POIKitHTTPReturnCode.STATUS_OK,
                      let prices = response.success else {
                    result(.failure(POIKit.POIKitAPIError.serverError))
                    return
                }

                result(.success(POIKit.RegionalPricesResponse(prices)))

            case .failure(let error):
                result(.failure(error))
            }
        }
    }

    func priceHistory(_ request: PriceHistoryRequest,
                      result: @escaping (Result<PCPOIPriceHistory, Error>) -> Void) {
        let apiRequest = POIAPI.PriceHistories.GetPriceHistory.Request(options: request.options)
        API.POI.client.makeRequest(apiRequest) { apiResult in
            switch apiResult.result {
            case .success(let response):
                guard response.statusCode == POIKitHTTPReturnCode.STATUS_OK,
                      let priceHistory = response.success?.data else {
                    result(.failure(POIKit.POIKitAPIError.serverError))
                    return
                }
                result(.success(priceHistory))

            case .failure(let error):
                result(.failure(error))
            }
        }
    }
}
