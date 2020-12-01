//
//  POIKitAPI+POIFilters.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

typealias POIFiltersResponse = POIKit.POIFiltersResponse

extension POIKitAPI {
    func filters(_ request: POIFiltersRequest,
                 result: @escaping (Result<POIFiltersResponse, Error>) -> Void) {
        let filterRequest = POIAPI.MetadataFilters.GetMetadataFilters.Request(options: request.options)
        self.request.client.makeRequest(filterRequest) { apiResult in
            switch apiResult.result {
            case .success(let response):
                guard response.statusCode == POIKitHTTPReturnCode.STATUS_OK,
                      let filters = response.success?.data else {
                    result(.failure(POIKit.POIKitAPIError.serverError))
                    return
                }

                let filterResponse = POIFiltersResponse(with: filters)

                result(.success(filterResponse))

            case .failure(let error):
                result(.failure(error))
            }
        }
    }
}
