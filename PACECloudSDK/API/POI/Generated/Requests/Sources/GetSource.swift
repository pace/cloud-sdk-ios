//
// Generated by SwagGen
// https://github.com/pace/SwagGen
//

import Foundation

extension POIAPI.Sources {

    /** Returns source with specified id */
    public enum GetSource {

        public static let service = APIService<Response>(id: "GetSource", tag: "Sources", method: "GET", path: "/beta/sources/{sourceId}", hasBody: false, securityRequirements: [SecurityRequirement(type: "OAuth2", scopes: ["poi:sources:read"]), SecurityRequirement(type: "OIDC", scopes: ["poi:sources:read"])])

        public final class Request: APIRequest<Response> {

            public struct Options {

                /** ID of the source */
                public var sourceId: ID?

                public init(sourceId: ID? = nil) {
                    self.sourceId = sourceId
                }
            }

            public var options: Options

            public init(options: Options) {
                self.options = options
                super.init(service: GetSource.service)
            }

            /// convenience initialiser so an Option doesn't have to be created
            public convenience init(sourceId: ID? = nil) {
                let options = Options(sourceId: sourceId)
                self.init(options: options)
            }

            public override var path: String {
                return super.path.replacingOccurrences(of: "{" + "sourceId" + "}", with: "\(self.options.sourceId?.encode() ?? "")")
            }
        }

        public enum Response: APIResponseValue, CustomStringConvertible, CustomDebugStringConvertible {

            /** Returns source with specified id */
            public class Status200: APIModel {

                public var data: PCSource?

                public init(data: PCSource? = nil) {
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

            /** The server cannot or will not process the request due to an apparent client error
 */
            case status400(PCErrors)

            /** OAuth token missing or invalid */
            case status401(PCErrors)

            /** Resource not found */
            case status404(PCErrors)

            /** The specified Accept header is not valid */
            case status406(PCErrors)

            /** A generic error message, given when an unexpected condition was encountered and no more specific message is suitable. */
            case status500(PCErrors)

            public var success: Status200? {
                switch self {
                case .status200(let response): return response
                default: return nil
                }
            }

            public var failure: PCErrors? {
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
            public var responseResult: APIResponseResult<Status200, PCErrors> {
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
                case 400: self = try .status400(decoder.decode(PCErrors.self, from: data))
                case 401: self = try .status401(decoder.decode(PCErrors.self, from: data))
                case 404: self = try .status404(decoder.decode(PCErrors.self, from: data))
                case 406: self = try .status406(decoder.decode(PCErrors.self, from: data))
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
