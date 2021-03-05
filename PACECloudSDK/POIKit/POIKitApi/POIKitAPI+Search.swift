//
//  POIKitApi+Search.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import CoreLocation
import MapKit
import UIKit

public extension POIKit {
    /** Request for an address search */
    class AddressSearchRequest {
        /** Creates a new instance of the search request. */
        public init() {}

        /**
         Preferred language order for showing search results, overrides the value specified in the "Accept-Language" HTTP header.
         Either uses standard rfc2616 accept-language string or a simple comma separated list of language codes.
         */
        open var acceptLanguage: [String] = []

        /**
         Query string to search for
         */
        open var text: String?

        /**
         The preferred area to find search results. Any two corner points of the box are accepted in any order as long as they span a real box.
         */
        open var locationBias: CLLocationCoordinate2D?

        /**
         Limit the number of returned results.
         Default is 10.
         */
        open var limit = 10

        open var includeKeys: [String] = []
        open var excludeValues: [String] = []

        var urlParams: [String: [String]] {
            var params: [String: [String]] = [:]

            if !acceptLanguage.isEmpty {
                if acceptLanguage.contains(where: ["de", "en", "it", "fr"].contains) {
                    params["lang"] = [acceptLanguage.joined(separator: ",")]
                }
            }

            if let text = text {
                params["q"] = [text]
            }

            if let locationBias = locationBias {
                params["lat"] = ["\(locationBias.latitude)"]
                params["lon"] = ["\(locationBias.longitude)"]
            }

            if !includeKeys.isEmpty {
                params["osm_tag"] = (params["osm_tag"] ?? []) + includeKeys.map { $0 }
            }

            if !excludeValues.isEmpty {
                params["osm_tag"] = (params["osm_tag"] ?? []) + excludeValues.map { ":!\($0)" }
            }

            params["limit"] = ["\(limit)"]

            return params
        }
    }

    struct GeoJSONResult: Codable {
        public var features: [GeoJSONFeature]
    }

    struct GeoJSONFeature: Codable {
        public var properties: GeoJSONProperty?
        public var type: String?
        public var geometry: GeoJSONGeometry?
    }

    struct GeoJSONProperty: Codable {
        public var name: String?
        public var street: String?
        public var housenumber: String?
        public var postcode: String?
        public var state: String?
        public var country: String?
        public var city: String?
        public var countrycode: String?
        public var osm_key: String?
        public var osm_value: String?
    }

    struct GeoJSONGeometry: Codable {
        public var type: String?
        public var coordinates: [Double]?

        public var clCoordinate: CLLocationCoordinate2D? {
            guard let coordinates = coordinates else { return nil }
            return CLLocationCoordinate2D(latitude: coordinates[1], longitude: coordinates[0])
        }

        public var clLocation: CLLocation? {
            guard let coordinates = coordinates else { return nil }
            return CLLocation(latitude: coordinates[1], longitude: coordinates[0])
        }
    }
}

var currentAutocompleteReq: Int64 = 0

extension POIKitAPI {
    // MARK: - Search

    func search(_ request: POIKit.AddressSearchRequest, handler: ((POIKit.GeoJSONResult?, POIKit.POIKitAPIError) -> Void)?) {
        guard let url = buildURL(.search, path: "", urlParams: request.urlParams) else {
            handler?(nil, POIKit.POIKitAPIError.unknown)
            return
        }

        self.request.httpRequest(.get, url: url, body: nil, includeDefaultHeaders: false, headers: [:], on: cloudQueue) { response, data, error -> Void in
            if let error = error as NSError?, error.code == NSURLError.notConnectedToInternet.rawValue {
                handler?(nil, .networkError)

                return
            }

            guard response?.statusCode == POIKitHTTPReturnCode.STATUS_OK else {
                handler?(nil, .serverError)
                return
            }

            guard let data = data, let searchResponse = try? JSONDecoder().decode(POIKit.GeoJSONResult.self, from: data) else {
                handler?(nil, .unknown)
                return
            }

            handler?(searchResponse, POIKit.POIKitAPIError.noError)
        }
    }

    // MARK: - Autocomplete

    private func delay(_ delay: Double, closure: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay, execute: closure)
    }

    func autocomplete(_ request: POIKit.AddressSearchRequest, isThrottled: Bool, handler: ((POIKit.GeoJSONResult?, POIKit.POIKitAPIError) -> Void)?) {
        guard isThrottled else {
            search(request, handler: handler)
            return
        }

        currentAutocompleteReq += 1
        let seq = currentAutocompleteReq

        delay(0.3) {
            if seq == currentAutocompleteReq {
                self.search(request, handler: handler)
            }
        }
    }
}
