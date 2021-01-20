//
// Generated by SwagGen
// https://github.com/pace/SwagGen
//

import Foundation

extension POIAPI.PriceHistories {

    /**
    Get price history for a specific gas station

    Get the price history for a specific gas station and fuel type on a period of time which can begin no sooner than 37 days ago; the time interval between price changes can be set to minute, hour, day, week, month or year
    */
    public enum GetPriceHistory {

        public static var service = POIAPIService<Response>(id: "GetPriceHistory", tag: "Price Histories", method: "GET", path: "/gas-stations/{id}/fuel-price-histories/{fuel_type}", hasBody: false, securityRequirements: [SecurityRequirement(type: "OAuth2", scopes: ["poi:gas-stations:read"])])

        public final class Request: POIAPIRequest<Response> {

            public struct Options {

                /** Gas station ID */
                public var id: ID

                /** Filter after a specific fuel type */
                public var fuelType: PCPOIFuel?

                /** Filters data from the given point in time */
                public var filterfrom: DateTime?

                /** Filters data to the given point in time */
                public var filterto: DateTime?

                /** Base time interval between price changes */
                public var filtergranularity: String?

                public init(id: ID, fuelType: PCPOIFuel? = nil, filterfrom: DateTime? = nil, filterto: DateTime? = nil, filtergranularity: String? = nil) {
                    self.id = id
                    self.fuelType = fuelType
                    self.filterfrom = filterfrom
                    self.filterto = filterto
                    self.filtergranularity = filtergranularity
                }
            }

            public var options: Options

            public init(options: Options) {
                self.options = options
                super.init(service: GetPriceHistory.service)
            }

            /// convenience initialiser so an Option doesn't have to be created
            public convenience init(id: ID, fuelType: PCPOIFuel? = nil, filterfrom: DateTime? = nil, filterto: DateTime? = nil, filtergranularity: String? = nil) {
                let options = Options(id: id, fuelType: fuelType, filterfrom: filterfrom, filterto: filterto, filtergranularity: filtergranularity)
                self.init(options: options)
            }

            public override var path: String {
                return super.path.replacingOccurrences(of: "{" + "id" + "}", with: "\(self.options.id.encode())").replacingOccurrences(of: "{" + "fuel_type" + "}", with: "\(self.options.fuelType?.encode() ?? "")")
            }

            public override var queryParameters: [String: Any] {
                var params: [String: Any] = [:]
                if let filterfrom = options.filterfrom?.encode() {
                  params["filter[from]"] = filterfrom
                }
                if let filterto = options.filterto?.encode() {
                  params["filter[to]"] = filterto
                }
                if let filtergranularity = options.filtergranularity {
                  params["filter[granularity]"] = filtergranularity
                }
                return params
            }
        }

        public enum Response: APIResponseValue, CustomStringConvertible, CustomDebugStringConvertible {

            /** Get the price history for a specific gas station and fuel type on a period of time which can begin no sooner than 37 days ago; the time interval between price changes can be set to minute, hour, day, week, month or year
             */
            public class Status200: APIModel {

                public var data: PCPOIPriceHistory?

                public init(data: PCPOIPriceHistory? = nil) {
                    self.data = data
                }

                public required init(from decoder: Decoder) throws {
                    let container = try decoder.container(keyedBy: StringCodingKey.self)

                    data = try container.decodeIfPresent("data")
                }

                public func encode(to encoder: Encoder) throws {
                    var container = encoder.container(keyedBy: StringCodingKey.self)

                    try container.encodeIfPresent(data, forKey: "data")
                }

                public func isEqual(to object: Any?) -> Bool {
                  guard let object = object as? Status200 else { return false }
                  guard self.data == object.data else { return false }
                  return true
                }

                public static func == (lhs: Status200, rhs: Status200) -> Bool {
                    return lhs.isEqual(to: rhs)
                }
            }
            public typealias SuccessType = Status200

            /** OK */
            case status200(Status200)

            /** Bad request */
            case status400(PCPOIErrors)

            /** OAuth token missing or invalid */
            case status401(PCPOIErrors)

            /** Resource not found */
            case status404(PCPOIErrors)

            /** The specified accept header is invalid */
            case status406(PCPOIErrors)

            /** Internal server error */
            case status500(PCPOIErrors)

            public var success: Status200? {
                switch self {
                case .status200(let response): return response
                default: return nil
                }
            }

            public var failure: PCPOIErrors? {
                switch self {
                case .status400(let response): return response
                case .status401(let response): return response
                case .status404(let response): return response
                case .status406(let response): return response
                case .status500(let response): return response
                default: return nil
                }
            }

            /// either success or failure value. Success is anything in the 200..<300 status code range
            public var responseResult: APIResponseResult<Status200, PCPOIErrors> {
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
                case .status404(let response): return response
                case .status406(let response): return response
                case .status500(let response): return response
                }
            }

            public var statusCode: Int {
                switch self {
                case .status200: return 200
                case .status400: return 400
                case .status401: return 401
                case .status404: return 404
                case .status406: return 406
                case .status500: return 500
                }
            }

            public var successful: Bool {
                switch self {
                case .status200: return true
                case .status400: return false
                case .status401: return false
                case .status404: return false
                case .status406: return false
                case .status500: return false
                }
            }

            public init(statusCode: Int, data: Data, decoder: ResponseDecoder) throws {
                switch statusCode {
                case 200: self = try .status200(decoder.decode(Status200.self, from: data))
                case 400: self = try .status400(decoder.decode(PCPOIErrors.self, from: data))
                case 401: self = try .status401(decoder.decode(PCPOIErrors.self, from: data))
                case 404: self = try .status404(decoder.decode(PCPOIErrors.self, from: data))
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
