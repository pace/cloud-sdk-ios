//
// Generated by SwagGen
// https://github.com/pace/SwagGen
//

import Foundation

extension POIAPI.Admin {

    /** Allows an admin to move a POI identified by its ID to a specific position */
    public enum MovePoiAtPosition {

        public static let service = APIService<Response>(id: "MovePoiAtPosition", tag: "Admin", method: "PATCH", path: "/beta/admin/poi/move", hasBody: true, securityRequirements: [SecurityRequirement(type: "OAuth2", scopes: ["poi:pois:update"]), SecurityRequirement(type: "OIDC", scopes: ["poi:pois:update"])])

        public final class Request: APIRequest<Response> {

            public init() {
                super.init(service: MovePoiAtPosition.service)
            }
        }

        public enum Response: APIResponseValue, CustomStringConvertible, CustomDebugStringConvertible {
            public typealias SuccessType = Void

            /** OK */
            case status204

            /** The server cannot or will not process the request due to an apparent client error
 */
            case status400(PCErrors)

            /** OAuth token missing or invalid */
            case status401(PCErrors)

            /** Resource not found */
            case status404(PCErrors)

            /** The specified Accept header is not valid */
            case status406(PCErrors)

            /** The specified Content-Type header is not valid */
            case status415(PCErrors)

            /** The request was well-formed but was unable to be followed due to semantic errors. */
            case status422(PCErrors)

            /** A generic error message, given when an unexpected condition was encountered and no more specific message is suitable. */
            case status500(PCErrors)

            public var success: Void? {
                switch self {
                case .status204: return ()
                default: return nil
                }
            }

            public var failure: PCErrors? {
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
            public var responseResult: APIResponseResult<Void, PCErrors> {
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
                case 400: self = try .status400(decoder.decode(PCErrors.self, from: data))
                case 401: self = try .status401(decoder.decode(PCErrors.self, from: data))
                case 404: self = try .status404(decoder.decode(PCErrors.self, from: data))
                case 406: self = try .status406(decoder.decode(PCErrors.self, from: data))
                case 415: self = try .status415(decoder.decode(PCErrors.self, from: data))
                case 422: self = try .status422(decoder.decode(PCErrors.self, from: data))
                case 500: self = try .status500(decoder.decode(PCErrors.self, from: data))
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
