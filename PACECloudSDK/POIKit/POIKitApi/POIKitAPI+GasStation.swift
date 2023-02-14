//
//  POIKitAPI+GasStation.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import CoreLocation
import Foundation

extension POIKitAPI {

    // MARK: - POIKit.GasStationResponse

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
                          let id = gasStation.id else {
                        result(.failure(APIClientError.unknownError(POIKit.POIKitAPIError.unknown)))
                        return
                    }

                    let response = POIKit.GasStationResponse(id: id,
                                                             gasStation: gasStation,
                                                             prices: gasStation.fuelPrices,
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

    // MARK: - [POIKit.GasStation]

    func gasStations(_ requests: [GasStationRequest], result: @escaping (Result<[POIKit.GasStation], Error>) -> Void) {
        guard !requests.isEmpty else {
            result(.success([]))
            return
        }

        let dispatchGroup = DispatchGroup()
        var poiStations: [POIKit.GasStation] = []
        var errors: [Error] = []

        requests.forEach {
            dispatchGroup.enter()
            poiStation($0) { result in
                defer {
                    dispatchGroup.leave()
                }

                switch result {
                case .success(let poiStation):
                    poiStations.append(poiStation)

                case .failure(let error):
                    errors.append(error)
                }
            }
        }

        dispatchGroup.notify(queue: .main) {
            if let mostRecentError = errors.last, poiStations.isEmpty {
                result(.failure(mostRecentError))
            } else {
                result(.success(poiStations))
            }
        }
    }

    private func poiStation(_ request: GasStationRequest, completion: @escaping (Result<POIKit.GasStation, Error>) -> Void) {
        gasStation(request) { [weak self] (result: Result<POIKit.GasStationResponse, Error>) in
            switch result {
            case .success(let response):
                guard let latitudeFloat = response.gasStation.latitude,
                      let longitudeFloat = response.gasStation.longitude else {
                    completion(.failure(POIKit.POIKitAPIError.unknown))
                    return
                }

                let latitude = Double(latitudeFloat)
                let longitude = Double(longitudeFloat)
                let location = CLLocation(latitude: latitude, longitude: longitude)

                _ = self?.fetchPOIs(locations: [location]) { result in
                    switch result {
                    case .success(let poiStations):
                        guard let poiStation = poiStations.first(where: { $0.id == request.id }) else {
                            completion(.failure(POIKit.POIKitAPIError.unknown))
                            return
                        }

                        completion(.success(poiStation))

                    case .failure(let error as POIKit.POIKitAPIError):
                        completion(.failure(error))

                    case .failure(let error):
                        completion(.failure(error))
                    }
                }

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
