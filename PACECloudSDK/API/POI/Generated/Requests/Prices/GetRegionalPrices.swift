//
// Generated by SwagGen
// https://github.com/pace/SwagGen
//

import Foundation

extension POIAPI.Prices {

    /**
    Search for regional prices in the area

    Search for regional prices in the area centered at input latitude/longitude. Lower/Upper limits are set for each fuel type returned.
    */
    public enum GetRegionalPrices {

        public static var service = POIAPIService<Response>(id: "GetRegionalPrices", tag: "Prices", method: "GET", path: "/prices/regional", hasBody: false, securityRequirements: [])

        public final class Request: POIAPIRequest<Response> {

            public struct Options {

                /** Latitude in degrees */
                public var filterlatitude: Float

                /** Longitude in degrees */
                public var filterlongitude: Float

                public init(filterlatitude: Float, filterlongitude: Float) {
                    self.filterlatitude = filterlatitude
                    self.filterlongitude = filterlongitude
                }
            }

            public var options: Options

            public init(options: Options) {
                self.options = options
                super.init(service: GetRegionalPrices.service)
            }

            /// convenience initialiser so an Option doesn't have to be created
            public convenience init(filterlatitude: Float, filterlongitude: Float) {
                let options = Options(filterlatitude: filterlatitude, filterlongitude: filterlongitude)
                self.init(options: options)
            }

            public override var queryParameters: [String: Any] {
                var params: [String: Any] = [:]
                params["filter[latitude]"] = options.filterlatitude
                params["filter[longitude]"] = options.filterlongitude
                return params
            }
        }

        public enum Response: APIResponseValue, CustomStringConvertible, CustomDebugStringConvertible {
            public typealias SuccessType = PCPOIRegionalPrices

            /** OK */
            case status200(PCPOIRegionalPrices)

            /** Bad request */
            case status400(PCPOIErrors)

            /** OAuth token missing or invalid */
            case status401(PCPOIErrors)

            /** The specified accept header is invalid */
            case status406(PCPOIErrors)

            /** Internal server error */
            case status500(PCPOIErrors)

            public var success: PCPOIRegionalPrices? {
                switch self {
                case .status200(let response): return response
                default: return nil
                }
            }

            public var failure: PCPOIErrors? {
                switch self {
                case .status400(let response): return response
                case .status401(let response): return response
                case .status406(let response): return response
                case .status500(let response): return response
                default: return nil
                }
            }

            /// either success or failure value. Success is anything in the 200..<300 status code range
            public var responseResult: APIResponseResult<PCPOIRegionalPrices, PCPOIErrors> {
                if let successValue = success {
                    return .success(successValue)
                } else if let failureValue = failure {
                    return .failure(failureValue)
                } else {
                    fatalError("Response does not have success or failure response")
                }
            }

            public var response: Any {
                switch self {
                case .status200(let response): return response
                case .status400(let response): return response
                case .status401(let response): return response
                case .status406(let response): return response
                case .status500(let response): return response
                }
            }

            public var statusCode: Int {
                switch self {
                case .status200: return 200
                case .status400: return 400
                case .status401: return 401
                case .status406: return 406
                case .status500: return 500
                }
            }

            public var successful: Bool {
                switch self {
                case .status200: return true
                case .status400: return false
                case .status401: return false
                case .status406: return false
                case .status500: return false
                }
            }

            public init(statusCode: Int, data: Data, decoder: ResponseDecoder) throws {
                switch statusCode {
                case 200: self = try .status200(decoder.decode(PCPOIRegionalPrices.self, from: data))
                case 400: self = try .status400(decoder.decode(PCPOIErrors.self, from: data))
                case 401: self = try .status401(decoder.decode(PCPOIErrors.self, from: data))
                case 406: self = try .status406(decoder.decode(PCPOIErrors.self, from: data))
                case 500: self = try .status500(decoder.decode(PCPOIErrors.self, from: data))
                default: throw APIClientError.unexpectedStatusCode(statusCode: statusCode, data: data)
                }
            }

            public var description: String {
                return "\(statusCode) \(successful ? "success" : "failure")"
            }

            public var debugDescription: String {
                var string = description
                let responseString = "\(response)"
                if responseString != "()" {
                    string += "\n\(responseString)"
                }
                return string
            }
        }
    }
}
