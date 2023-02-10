//
//  POIKitAPI+GasStation.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import CoreLocation
import Foundation

extension POIKitAPI {
    func gasStation(_ request: GasStationRequest, // swiftlint:disable:this cyclomatic_complexity
                    result: @escaping (Result<POIKit.GasStationResponse, Error>) -> Void) {
        let apiRequest = POIAPI.GasStations.GetGasStation.Request(id: request.id)
        API.POI.client.makeRequest(apiRequest) { apiResult in
            switch apiResult.result {
            case .success(let response):

                guard let httpResponse = apiResult.urlResponse else {
                    result(.failure(POIKit.POIKitAPIError.unknown))

                    return
                }

                switch response.statusCode {
                case POIKitHTTPReturnCode.NOT_FOUND:
                    result(.failure(POIKit.POIKitAPIError.notFound))

                case POIKitHTTPReturnCode.AUTH_FAILED:
                    result(.failure(POIKit.POIKitAPIError.unauthorized))

                case POIKitHTTPReturnCode.NOT_ACCEPTABLE:
                    result(.failure(POIKit.POIKitAPIError.requestError))

                case POIKitHTTPReturnCode.GONE:
                    result(.failure(POIKit.POIKitAPIError.notFound))

                case POIKitHTTPReturnCode.MOVED_PERMANENTLY:
                    self.handleMovedPOI(response: httpResponse, result: result)

                case POIKitHTTPReturnCode.STATUS_OK:
                    guard let gasStation = response.success?.data,
                          let id = gasStation.id,
                          let prices = gasStation.fuelPrices else {
                        result(.failure(APIClientError.unknownError(POIKit.POIKitAPIError.unknown)))
                        return
                    }

                    let response = POIKit.GasStationResponse(id: id,
                                                             gasStation: gasStation,
                                                             prices: prices,
                                                             wasMoved: false)
                    result(.success(response))

                default:
                    result(.failure(POIKit.POIKitAPIError.unknown))
                }

            case .failure(let error):
                result(.failure(error))
            }
        }
    }

    private func handleMovedPOI(response: HTTPURLResponse, result: @escaping (Result<POIKit.GasStationResponse, Error>) -> Void) {
        var location: String

        if #available(iOS 13.0, *) {
            location = response.value(forHTTPHeaderField: "Location") ?? ""
        } else {
            location = response.allHeaderFields["Location"] as? String ?? ""
        }

        guard !location.isEmpty, let uuidComponent = location.split(separator: "/").last else {
            result(.failure(POIKit.POIKitAPIError.notFound))
            return
        }

        let newUUID = String(uuidComponent)

        // Run the request again with the newly acquired UUID
        self.gasStation(GasStationRequest(id: newUUID)) { nestedResult in
            switch nestedResult {
            case .success(let response):
                var gasStation = response
                gasStation.wasMoved = true
                result(.success(gasStation))

            case .failure(let error):
                result(.failure(error))
            }
        }
    }
}
