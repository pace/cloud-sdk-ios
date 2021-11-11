//
//  POIKitAPI+Routing.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

extension POIKitAPI {
    func route(_ request: POIKit.NavigationRequest, handler: ((POIKit.NavigationResponse?, POIKit.POIKitAPIError) -> Void)?) {
        let coordinatesString = request.coordinates
            .map({ "\($0.longitude),\($0.latitude)" })
            .joined(separator: ";")

        guard let url = buildURL(.osrm, path: "/\(request.navigationMode.rawValue)/\(coordinatesString)", urlParams: request.toUrlParams()) else {
            handler?(nil, .unknown)
            return
        }

        self.request.httpRequest(.get, url: url, body: nil, includeDefaultHeaders: true, headers: [:], on: cloudQueue) { response, data, _ in
            if response?.statusCode != POIKitHTTPReturnCode.STATUS_OK {
                handler?(nil, .serverError)
                return
            }

            // Check response
            guard let data = data,
                  let navigationResponse = try? JSONDecoder().decode(POIKit.NavigationResponse.self, from: data) else {
                    handler?(nil, .unknown)
                    return
            }

            navigationResponse.routes.forEach { $0.navigationMode = request.navigationMode }

            handler?(navigationResponse, .noError)
        }
    }
}
