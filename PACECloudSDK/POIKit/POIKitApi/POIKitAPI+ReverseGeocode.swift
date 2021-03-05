//
//  POIKitAPI+ReverseGeocoding.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import CoreLocation
import MapKit
import UIKit

public extension POIKit {
    /** Request for reverse geocoding a location */
    class ReverseGeocodeRequest {
        /** Creates a new instance of the search request. */
        public init() {}

        /** The location which should be reverse geocoded */
        open var location: CLLocationCoordinate2D?

        /**
         Preferred language order for showing search results, overrides the value specified in the "Accept-Language" HTTP header.
         Either uses standard rfc2616 accept-language string or a simple comma separated list of language codes.
         */
        open var acceptLanguage: [String] = []

        var urlParams: [String: [String]] {
            var params: [String: [String]] = [:]

            if !acceptLanguage.isEmpty {
                if acceptLanguage.contains(where: ["de", "en", "it", "fr"].contains) {
                    params["lang"] = [acceptLanguage.joined(separator: ",")]
                }
            }

            if let location = location {
                params["lat"] = ["\(location.latitude)"]
                params["lon"] = ["\(location.longitude)"]
            }

            return params
        }
    }
}

extension POIKitAPI {
    // MARK: - Reverse Geocode

    func reverseGeocode(_ request: POIKit.ReverseGeocodeRequest, handler: ((POIKit.GeoJSONResult?, POIKit.POIKitAPIError) -> Void)?) {
        guard let url = buildURL(.reverseGeocode, path: "", urlParams: request.urlParams) else {
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
}
