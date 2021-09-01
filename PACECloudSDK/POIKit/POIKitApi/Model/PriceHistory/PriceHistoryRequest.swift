//
//  PriceHistoryRequest.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

public extension POIKit {
    class PriceHistoryRequest<T: AnyPriceHistoryResponse> {
        public var customHeaders: [String: String] = [:]

        var queryParams: [String: [String]] {
            let sinceFormatted = ISO8601DateFormatter().string(from: since)
            return
                [
                    "filter[since]": [sinceFormatted],
                    "granularity": [granularity],
                    "forecast": ["\(includesForecast)"]
                ]
        }

        var path: String {
            ""
        }

        var responseType: T.Type {
            T.self
        }

        private let since: Date
        private let granularity: String
        private let includesForecast: Bool

        init(since: Date, granularity: String, includesForecast: Bool = false) {
            self.since = since
            self.granularity = granularity
            self.includesForecast = includesForecast
        }
    }

    class PriceHistoryGasStationRequest: PriceHistoryRequest<[PriceHistoryResponse]> {
        private let stationId: String

        override var path: String {
            "/prices/fueling/stations/\(stationId)"
        }

        /**
         The price history request.

         - parameter stationId: The id of the gas station.
         - parameter since: Must be less than now and not more than 1 year ago.
         - parameter granularity: Number&Unit (m,d,w,M,y); Example: 15m.
         - parameter includesForecast: Determines if the response includes a price forecast.
         */
        public init(stationId: String,
                    since: Date,
                    granularity: String,
                    includesForecast: Bool = false) {
            self.stationId = stationId
            super.init(since: since, granularity: granularity, includesForecast: includesForecast)
        }
    }

    class PriceHistoryGasStationFuelTypeRequest: PriceHistoryRequest<[PriceHistoryFuelTypeResponse]> {
        private let stationId: String
        private let fuelType: String

        override var path: String {
            "/prices/fueling/stations/\(stationId)/\(fuelType)"
        }

        /**
         The price history request.

         - parameter fuelType: The fuel type of the price history.
         - parameter stationId: The id of the gas station.
         - parameter since: Must be less than now and not more than 1 year ago.
         - parameter granularity: Number&Unit (m,d,w,M,y); Example: 15m.
         - parameter includesForecast: Determines if the response includes a price forecast.
         */
        public init(stationId: String,
                    fuelType: String,
                    since: Date,
                    granularity: String,
                    includesForecast: Bool = false) {
            self.stationId = stationId
            self.fuelType = fuelType
            super.init(since: since,
                       granularity: granularity,
                       includesForecast: includesForecast)
        }
    }

    class PriceHistoryCountryRequest: PriceHistoryRequest<PriceHistoryResponse> {
        private let countryCode: String

        override var path: String {
            "/prices/fueling/countries/\(countryCode)"
        }

        /**
         The price history request.

         - parameter countryCode: The country code.
         - parameter since: Must be less than now and not more than 1 year ago.
         - parameter granularity: Number&Unit (m,d,w,M,y); Example: 15m.
         - parameter includesForecast: Determines if the response includes a price forecast.
         */
        public init(countryCode: String,
                    since: Date,
                    granularity: String,
                    includesForecast: Bool = false) {
            self.countryCode = countryCode
            super.init(since: since,
                       granularity: granularity,
                       includesForecast: includesForecast)
        }
    }

    class PriceHistoryCountryFuelTypeRequest: PriceHistoryRequest<PriceHistoryFuelTypeResponse> {
        private let countryCode: String
        private let fuelType: String

        override var path: String {
            "/prices/fueling/countries/\(countryCode)/\(fuelType)"
        }

        /**
         The price history request.

         - parameter fuelType: The fuel type of the price history.
         - parameter countryCode: The country code.
         - parameter since: Must be less than now and not more than 1 year ago.
         - parameter granularity: Number&Unit (m,d,w,M,y); Example: 15m.
         - parameter includesForecast: Determines if the response includes a price forecast.
         */
        public init(countryCode: String,
                    fuelType: String,
                    since: Date,
                    granularity: String,
                    includesForecast: Bool = false) {
            self.countryCode = countryCode
            self.fuelType = fuelType
            super.init(since: since,
                       granularity: granularity,
                       includesForecast: includesForecast)
        }
    }
}
