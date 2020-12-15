//
// Generated by SwagGen
// https://github.com/pace/SwagGen
//

import Foundation

extension POIAPI.GasStations {

    /**
    Get a specific gas station

    Returns an individual gas station
    */
    public enum GetGasStation {

        public static var service = POIAPIService<Response>(id: "GetGasStation", tag: "Gas Stations", method: "GET", path: "/gas-stations/{id}", hasBody: false, securityRequirements: [SecurityRequirement(type: "OAuth2", scopes: ["poi:gas-stations:read", "poi:gas-stations.references:read"]), SecurityRequirement(type: "OIDC", scopes: ["poi:gas-stations:read", "poi:gas-stations.references:read"])])

        public final class Request: POIAPIRequest<Response> {

            public struct Options {

                /** Gas station ID */
                public var id: ID

                /** Reduces the opening hours rules. After compilation, only rules with the action open will remain in the response. */
                public var compileopeningHours: Bool?

                public init(id: ID, compileopeningHours: Bool? = nil) {
                    self.id = id
                    self.compileopeningHours = compileopeningHours
                }
            }

            public var options: Options

            public init(options: Options) {
                self.options = options
                super.init(service: GetGasStation.service)
            }

            /// convenience initialiser so an Option doesn't have to be created
            public convenience init(id: ID, compileopeningHours: Bool? = nil) {
                let options = Options(id: id, compileopeningHours: compileopeningHours)
                self.init(options: options)
            }

            public override var path: String {
                return super.path.replacingOccurrences(of: "{" + "id" + "}", with: "\(self.options.id.encode())")
            }

            public override var queryParameters: [String: Any] {
                var params: [String: Any] = [:]
                if let compileopeningHours = options.compileopeningHours {
                  params["compile[openingHours]"] = compileopeningHours
                }
                return params
            }
        }

        public enum Response: APIResponseValue, CustomStringConvertible, CustomDebugStringConvertible {

            /** Returns an individual gas station
             */
            public class Status200: APIModel {

                public var data: PCPOIGasStation?

                public var included: [Poly3<PCPOIFuelPrice,PCPOILocationBasedApp,PCPOIReferenceStatus>]?

                public init(data: PCPOIGasStation? = nil, included: [Poly3<PCPOIFuelPrice,PCPOILocationBasedApp,PCPOIReferenceStatus>]? = nil) {
                    self.data = data
                    self.included = included
                }

                public required init(from decoder: Decoder) throws {
                    let container = try decoder.container(keyedBy: StringCodingKey.self)

                    data = try container.decodeIfPresent("data")
                    included = try container.decodeArrayIfPresent("included")
                }

                public func encode(to encoder: Encoder) throws {
                    var container = encoder.container(keyedBy: StringCodingKey.self)

                    try container.encodeIfPresent(data, forKey: "data")
                    try container.encodeIfPresent(included, forKey: "included")
                }

                public func isEqual(to object: Any?) -> Bool {
                  guard let object = object as? Status200 else { return false }
                  guard self.data == object.data else { return false }
                  guard self.included == object.included else { return false }
                  return true
                }

                public static func == (lhs: Status200, rhs: Status200) -> Bool {
                    return lhs.isEqual(to: rhs)
                }
            }
            public typealias SuccessType = Status200

            /** OK */
            case status200(Status200)

            /** Resource was permanently moved to new location */
            case status301

            /** OAuth token missing or invalid */
            case status401(PCPOIErrors)

            /** Resource not found */
            case status404(PCPOIErrors)

            /** The specified accept header is invalid */
            case status406(PCPOIErrors)

            /** Resource is expired */
            case status410(PCPOIErrors)

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
                case .status401(let response): return response
                case .status404(let response): return response
                case .status406(let response): return response
                case .status410(let response): return response
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
                case .status401(let response): return response
                case .status404(let response): return response
                case .status406(let response): return response
                case .status410(let response): return response
                case .status500(let response): return response
                default: return ()
                }
            }

            public var statusCode: Int {
                switch self {
                case .status200: return 200
                case .status301: return 301
                case .status401: return 401
                case .status404: return 404
                case .status406: return 406
                case .status410: return 410
                case .status500: return 500
                }
            }

            public var successful: Bool {
                switch self {
                case .status200: return true
                case .status301: return false
                case .status401: return false
                case .status404: return false
                case .status406: return false
                case .status410: return false
                case .status500: return false
                }
            }

            public init(statusCode: Int, data: Data, decoder: ResponseDecoder) throws {
                switch statusCode {
                case 200: self = try .status200(decoder.decode(Status200.self, from: data))
                case 301: self = .status301
                case 401: self = try .status401(decoder.decode(PCPOIErrors.self, from: data))
                case 404: self = try .status404(decoder.decode(PCPOIErrors.self, from: data))
                case 406: self = try .status406(decoder.decode(PCPOIErrors.self, from: data))
                case 410: self = try .status410(decoder.decode(PCPOIErrors.self, from: data))
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
