//
// Generated by SwagGen
// https://github.com/pace/SwagGen
//

import Foundation

extension POIAPI.Sources {

    /** Updates source with specified id */
    public enum UpdateSource {

        public static var service = POIAPIService<Response>(id: "UpdateSource", tag: "Sources", method: "PUT", path: "/sources/{sourceId}", hasBody: true, securityRequirements: [SecurityRequirement(type: "OAuth2", scopes: ["poi:sources:update"]), SecurityRequirement(type: "OIDC", scopes: ["poi:sources:update"])])

        public final class Request: POIAPIRequest<Response> {

            /** Updates source with specified id */
            public class Body: APIModel {

                public var data: PCPOISource?

                public init(data: PCPOISource? = nil) {
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

            public struct Options {

                /** ID of the source */
                public var sourceId: ID?

                public init(sourceId: ID? = nil) {
                    self.sourceId = sourceId
                }
            }

            public var options: Options

            public var body: Body

            public init(body: Body, options: Options, encoder: RequestEncoder? = nil) {
                self.body = body
                self.options = options
                super.init(service: UpdateSource.service) { defaultEncoder in
                    return try (encoder ?? defaultEncoder).encode(body)
                }
                self.contentType = "application/vnd.api+json"
            }

            /// convenience initialiser so an Option doesn't have to be created
            public convenience init(sourceId: ID? = nil, body: Body) {
                let options = Options(sourceId: sourceId)
                self.init(body: body, options: options)
            }

            public override var path: String {
                return super.path.replacingOccurrences(of: "{" + "sourceId" + "}", with: "\(self.options.sourceId?.encode() ?? "")")
            }
        }

        public enum Response: APIResponseValue, CustomStringConvertible, CustomDebugStringConvertible {

            /** Updates source with specified id */
            public class Status200: APIModel {

                public var data: PCPOISource?

                public init(data: PCPOISource? = nil) {
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

            /** The specified content type header is invalid */
            case status415(PCPOIErrors)

            /** The request was well-formed but was unable to be followed due to semantic errors. */
            case status422(PCPOIErrors)

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
                case .status415(let response): return response
                case .status422(let response): return response
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
                case .status415(let response): return response
                case .status422(let response): return response
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
                case .status415: return 415
                case .status422: return 422
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
                case .status415: return false
                case .status422: return false
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
