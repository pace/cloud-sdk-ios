//
//  POIKitAPI+GasStation.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import CoreLocation
import Foundation

extension POIKitAPI {
    func gasStation(_ request: GasStationRequest,
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
                    return

                case POIKitHTTPReturnCode.STATUS_OK:
                    guard let gasStation = response.success?.data,
                          let prices = response.success?.included?[PCPOIFuelPrice.self] else {
                        result(.failure(APIClientError.unknownError(POIKit.POIKitAPIError.unknown)))
                        return
                    }
                    self.handlePOIResponse(gasStation: gasStation,
                                           prices: prices,
                                           result: result)
                    return

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

    private func handlePOIResponse(gasStation: PCPOIGasStation,
                                   prices: [PCPOIFuelPrice],
                                   result: @escaping (Result<POIKit.GasStationResponse, Error>) -> Void) {
        guard let id = gasStation.id,
              let latitudeFloat = gasStation.attributes?.latitude,
              let longitudeFloat = gasStation.attributes?.longitude else {
            result(.failure(APIClientError.unknownError(POIKit.POIKitAPIError.unknown)))
            return
        }

        let latitude = Double(latitudeFloat)
        let longitude = Double(longitudeFloat)

        // Add gas station to database, if it does not exist yet
        let delegate = POIKit.Database.shared.delegate
        if delegate?.get(uuid: id) == nil {
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let gasStation = POIKit.GasStation(id: id, coordinate: coordinate)
            delegate?.add(gasStation)
        }

        let response = POIKit.GasStationResponse(id: id,
                                                 gasStation: gasStation,
                                                 prices: prices,
                                                 wasMoved: false)

        result(.success(response))
    }
}
