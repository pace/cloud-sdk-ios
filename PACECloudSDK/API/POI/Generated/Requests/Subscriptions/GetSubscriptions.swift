//
// Generated by SwagGen
// https://github.com/pace/SwagGen
//

import Foundation

extension POIAPI.Subscriptions {

    /**
    Get the list of POI subscriptions for the user or device

    Returns a list of all current (not expired) subscriptions of the user.
    */
    public enum GetSubscriptions {

        public static var service = POIAPIService<Response>(id: "GetSubscriptions", tag: "Subscriptions", method: "GET", path: "/subscriptions", hasBody: true, securityRequirements: [SecurityRequirement(type: "OAuth2", scopes: ["poi:subscriptions:read"]), SecurityRequirement(type: "OIDC", scopes: ["poi:subscriptions:read"]), SecurityRequirement(type: "DeviceID", scopes: [])])

        public final class Request: POIAPIRequest<Response> {

            public init() {
                super.init(service: GetSubscriptions.service)
            }
        }

        public enum Response: APIResponseValue, CustomStringConvertible, CustomDebugStringConvertible {

            /** Returns a list of all current (not expired) subscriptions of the user.
             */
            public class Status200: APIModel {

                public var data: PCPOISubscription?

                public init(data: PCPOISubscription? = nil) {
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
                }
            }

            public var statusCode: Int {
                switch self {
                case .status200: return 200
                case .status400: return 400
                case .status401: return 401
                case .status406: return 406
                }
            }

            public var successful: Bool {
                switch self {
                case .status200: return true
                case .status400: return false
                case .status401: return false
                case .status406: return false
                }
            }

            public init(statusCode: Int, data: Data, decoder: ResponseDecoder) throws {
                switch statusCode {
                case 200: self = try .status200(decoder.decode(Status200.self, from: data))
                case 400: self = try .status400(decoder.decode(PCPOIErrors.self, from: data))
                case 401: self = try .status401(decoder.decode(PCPOIErrors.self, from: data))
                case 406: self = try .status406(decoder.decode(PCPOIErrors.self, from: data))
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
