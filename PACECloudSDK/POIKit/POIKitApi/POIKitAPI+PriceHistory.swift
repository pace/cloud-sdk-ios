//
//  POIKitAPI+PriceHistory.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

extension POIKitAPI {
    func priceHistory<T: AnyPriceHistoryResponse>(_ request: POIKit.PriceHistoryRequest<T>,
                                               result: @escaping (Result<T, Error>) -> Void) {
        guard let url = buildURL(.priceService, path: request.path, urlParams: request.queryParams) else {
            result(.failure(POIKit.POIKitAPIError.unknown))
            return
        }

        self.request.httpRequest(.get, url: url, body: nil, includeDefaultHeaders: false, headers: request.customHeaders, on: cloudQueue) { response, data, error -> Void in
            if let error = error as NSError?, error.code == NSURLError.notConnectedToInternet.rawValue {
                result(.failure(POIKit.POIKitAPIError.networkError))
                return
            }

            if response?.statusCode == POIKitHTTPReturnCode.AUTH_FAILED {
                result(.failure(POIKit.POIKitAPIError.unauthorized))
                return
            }

            guard response?.statusCode == POIKitHTTPReturnCode.STATUS_OK else {
                result(.failure(POIKit.POIKitAPIError.serverError))
                return
            }

            guard let data = data, let priceHistoryResponse = try? JSONDecoder().decode(request.responseType, from: data) else {
                result(.failure(POIKit.POIKitAPIError.unknown))
                return
            }

            result(.success(priceHistoryResponse))
        }
    }
}
