//
//  POIKitAPI+GeoJSON.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import CoreLocation
import MapKit
import UIKit

public extension POIKit {
    enum GeoJSONRequestFields: String {
        case type
        case address
        case stationName
        case brand
        case dkvStationID
    }

    enum GeoJSONRequestPOIType: String {
        case gasStation = "GasStation"
        case speedCamera = "SpeedCamera"
    }

    enum GeoJSONRequestCountry: String {
        case de = "DE"
    }

    class GeoJSONRequest {
        public let poiType: GeoJSONRequestPOIType
        public let country: GeoJSONRequestCountry?
        public let isConnectedFuelingAvailable: Bool
        public let fields: [GeoJSONRequestFields]?
        public let isDKVAppAndGoAvailable: Bool?

        public init(poiType: GeoJSONRequestPOIType = .gasStation,
                    country: GeoJSONRequestCountry? = .de,
                    isConnectedFuelingAvailable: Bool,
                    fields: [GeoJSONRequestFields]? = nil,
                    isDKVAppAndGoAvailable: Bool? = nil) {
            self.poiType = poiType
            self.country = country
            self.isConnectedFuelingAvailable = isConnectedFuelingAvailable
            self.fields = fields
            self.isDKVAppAndGoAvailable = isDKVAppAndGoAvailable
        }

        var urlParams: [String: [String]] {
            var params: [String: [String]] = [:]

            params["filter[poiType]"] = [poiType.rawValue]

            if let country = country {
                params["filter[country]"] = [country.rawValue]
            }

            params["filter[connectedFueling]"] = isConnectedFuelingAvailable ? ["y"] : ["n"]

            if let fields = fields {
                let value = fields.map { $0.rawValue }.joined(separator: ",")
                params["fields[gasStation]"] = [value]
            }

            if let isDKVAppAndGoAvailable = isDKVAppAndGoAvailable {
                params["filter[dkvAppAndGo]"] = isDKVAppAndGoAvailable ? ["y"] : ["n"]
            }

            return params
        }
    }
}

extension POIKitAPI {
    func geoJson(_ request: POIKit.GeoJSONRequest, handler: @escaping (Result<POIKit.GeoJSONResponse, Error>) -> Void) {
        guard let url = buildURL(.poiApi, path: "/beta/geojson/pois", urlParams: request.urlParams) else {
            handler(.failure(POIKit.POIKitAPIError.unknown))
            return
        }

        self.request.httpRequest(.get, url: url, body: nil, includeDefaultHeaders: false, headers: [:]) { response, data, error -> Void in
            if let error = error as NSError?, error.code == NSURLError.notConnectedToInternet.rawValue {
                handler(.failure(POIKit.POIKitAPIError.networkError))
                return
            }

            guard response?.statusCode == POIKitHTTPReturnCode.STATUS_OK else {
                handler(.failure(POIKit.POIKitAPIError.serverError))
                return
            }

            guard let data = data, let response = try? JSONDecoder().decode(POIKit.GeoJSONResponse.self, from: data) else {
                handler(.failure(POIKit.POIKitAPIError.unknown))
                return
            }

            handler(.success(response))
        }
    }
}
