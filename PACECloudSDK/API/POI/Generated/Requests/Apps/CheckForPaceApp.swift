//
// Generated by SwagGen
// https://github.com/pace/SwagGen
//

import Foundation

extension POIAPI.Apps {

    /**
    Query for location-based apps

    These location-based PACE apps deliver additional services for PACE customers based on their current position.
You can (or should) trigger this whenever:
* A longer stand-still is detected
* The engine is turned off
* Every 5 seconds if the user "left the road"
Please note that calling this API is very cheap and can be done regularly.
    */
    public enum CheckForPaceApp {

        public static var service = POIAPIService<Response>(id: "CheckForPaceApp", tag: "Apps", method: "GET", path: "/apps/query", hasBody: false, securityRequirements: [SecurityRequirement(type: "OAuth2", scopes: ["poi:apps:read"]), SecurityRequirement(type: "OIDC", scopes: ["poi:apps:read"])])

        /** Type of location-based app */
        public enum PCPOIFilterappType: String, Codable, Equatable, CaseIterable {
            case fueling = "fueling"
        }

        public final class Request: POIAPIRequest<Response> {

            public struct Options {

                /** Latitude */
                public var filterlatitude: Float

                /** Longitude */
                public var filterlongitude: Float

                /** Type of location-based app */
                public var filterappType: PCPOIFilterappType?

                public init(filterlatitude: Float, filterlongitude: Float, filterappType: PCPOIFilterappType? = nil) {
                    self.filterlatitude = filterlatitude
                    self.filterlongitude = filterlongitude
                    self.filterappType = filterappType
                }
            }

            public var options: Options

            public init(options: Options) {
                self.options = options
                super.init(service: CheckForPaceApp.service)
            }

            /// convenience initialiser so an Option doesn't have to be created
            public convenience init(filterlatitude: Float, filterlongitude: Float, filterappType: PCPOIFilterappType? = nil) {
                let options = Options(filterlatitude: filterlatitude, filterlongitude: filterlongitude, filterappType: filterappType)
                self.init(options: options)
            }

            public override var queryParameters: [String: Any] {
                var params: [String: Any] = [:]
                params["filter[latitude]"] = options.filterlatitude
                params["filter[longitude]"] = options.filterlongitude
                if let filterappType = options.filterappType?.encode() {
                  params["filter[appType]"] = filterappType
                }
                return params
            }
        }

        public enum Response: APIResponseValue, CustomStringConvertible, CustomDebugStringConvertible {

            /** These location-based PACE apps deliver additional services for PACE customers based on their current position.
            You can (or should) trigger this whenever:
            * A longer stand-still is detected
            * The engine is turned off
            * Every 5 seconds if the user "left the road"
            Please note that calling this API is very cheap and can be done regularly.
             */
            public class Status200: APIModel {

                public var data: PCPOILocationBasedAppsWithRefs?

                public init(data: PCPOILocationBasedAppsWithRefs? = nil) {
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
                case 200: self = try .status200(decoder.decode(Status200.self, from: data))
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
