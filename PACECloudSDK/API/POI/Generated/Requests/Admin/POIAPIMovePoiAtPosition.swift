//
// Generated by SwagGen
// https://github.com/pace/SwagGen
//

import Foundation

extension POIAPI.Admin {

    /** Allows an admin to move a POI identified by its ID to a specific position */
    public enum MovePoiAtPosition {

        public static var service = POIAPIService<Response>(id: "MovePoiAtPosition", tag: "Admin", method: "PATCH", path: "/admin/poi/move", hasBody: true, securityRequirements: [SecurityRequirement(type: "OAuth2", scopes: ["poi:pois:update"]), SecurityRequirement(type: "OIDC", scopes: ["poi:pois:update"])])

        public final class Request: POIAPIRequest<Response> {

            public class Body: APIModel {

                public var data: PCPOIMoveRequest?

                public init(data: PCPOIMoveRequest? = nil) {
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
                  guard let object = object as? Body else { return false }
                  guard self.data == object.data else { return false }
                  return true
                }

                public static func == (lhs: Body, rhs: Body) -> Bool {
                    return lhs.isEqual(to: rhs)
                }
            }

            public var body: Body

            public init(body: Body, encoder: RequestEncoder? = nil) {
                self.body = body
                super.init(service: MovePoiAtPosition.service) { defaultEncoder in
                    return try (encoder ?? defaultEncoder).encode(body)
                }
                self.contentType = "application/vnd.api+json"
            }
        }

        public enum Response: APIResponseValue, CustomStringConvertible, CustomDebugStringConvertible {
            public typealias SuccessType = Void

            /** OK */
            case status204

            /** Bad request */
            case status400(PCPOIErrors)

            /** OAuth token missing or invalid */
            case status401(PCPOIErrors)

            /** Resource not found */
            case status404(PCPOIErrors)

            /** The specified accept header is invalid */
            case status406(PCPOIErrors)

            /** The specified content type header is invalid */
            case status415(PCPOIErrors)

            /** The request was well-formed but was unable to be followed due to semantic errors. */
            case status422(PCPOIErrors)

            /** Internal server error */
            case status500(PCPOIErrors)

            public var success: Void? {
                switch self {
                case .status204: return ()
                default: return nil
                }
            }

            public var failure: PCPOIErrors? {
                switch self {
                case .status400(let response): return response
                case .status401(let response): return response
                case .status404(let response): return response
                case .status406(let response): return response
                case .status415(let response): return response
                case .status422(let response): return response
                case .status500(let response): return response
                default: return nil
                }
            }

            /// either success or failure value. Success is anything in the 200..<300 status code range
            public var responseResult: APIResponseResult<Void, PCPOIErrors> {
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
                case .status400(let response): return response
                case .status401(let response): return response
                case .status404(let response): return response
                case .status406(let response): return response
                case .status415(let response): return response
                case .status422(let response): return response
                case .status500(let response): return response
                default: return ()
                }
            }

            public var statusCode: Int {
                switch self {
                case .status204: return 204
                case .status400: return 400
                case .status401: return 401
                case .status404: return 404
                case .status406: return 406
                case .status415: return 415
                case .status422: return 422
                case .status500: return 500
                }
            }

            public var successful: Bool {
                switch self {
                case .status204: return true
                case .status400: return false
                case .status401: return false
                case .status404: return false
                case .status406: return false
                case .status415: return false
                case .status422: return false
                case .status500: return false
                }
            }

            public init(statusCode: Int, data: Data, decoder: ResponseDecoder) throws {
                switch statusCode {
                case 204: self = .status204
                case 400: self = try .status400(decoder.decode(PCPOIErrors.self, from: data))
                case 401: self = try .status401(decoder.decode(PCPOIErrors.self, from: data))
                case 404: self = try .status404(decoder.decode(PCPOIErrors.self, from: data))
                case 406: self = try .status406(decoder.decode(PCPOIErrors.self, from: data))
                case 415: self = try .status415(decoder.decode(PCPOIErrors.self, from: data))
                case 422: self = try .status422(decoder.decode(PCPOIErrors.self, from: data))
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
