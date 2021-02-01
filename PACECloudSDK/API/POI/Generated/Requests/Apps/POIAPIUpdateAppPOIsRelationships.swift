//
// Generated by SwagGen
// https://github.com/pace/SwagGen
//

import Foundation

extension POIAPI.Apps {

    /** Update all POI relations for specified app id */
    public enum UpdateAppPOIsRelationships {

        public static var service = POIAPIService<Response>(id: "UpdateAppPOIsRelationships", tag: "Apps", method: "PATCH", path: "/apps/{appID}/relationships/pois", hasBody: true, securityRequirements: [SecurityRequirement(type: "OAuth2", scopes: ["poi:apps:update"]), SecurityRequirement(type: "OIDC", scopes: ["poi:apps:update"])])

        public final class Request: POIAPIRequest<Response> {

            public struct Options {

                /** ID of the App */
                public var appID: ID?

                public init(appID: ID? = nil) {
                    self.appID = appID
                }
            }

            public var options: Options

            public var body: PCPOIAppPOIsRelationships

            public init(body: PCPOIAppPOIsRelationships, options: Options, encoder: RequestEncoder? = nil) {
                self.body = body
                self.options = options
                super.init(service: UpdateAppPOIsRelationships.service) { defaultEncoder in
                    return try (encoder ?? defaultEncoder).encode(body)
                }
            }

            /// convenience initialiser so an Option doesn't have to be created
            public convenience init(appID: ID? = nil, body: PCPOIAppPOIsRelationships) {
                let options = Options(appID: appID)
                self.init(body: body, options: options)
            }

            public override var path: String {
                return super.path.replacingOccurrences(of: "{" + "appID" + "}", with: "\(self.options.appID?.encode() ?? "")")
            }
        }

        public enum Response: APIResponseValue, CustomStringConvertible, CustomDebugStringConvertible {
            public typealias SuccessType = PCPOIAppPOIsRelationships

            /** OK */
            case status200(PCPOIAppPOIsRelationships)

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

            public var success: PCPOIAppPOIsRelationships? {
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
            public var responseResult: APIResponseResult<PCPOIAppPOIsRelationships, PCPOIErrors> {
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
                case 200: self = try .status200(decoder.decode(PCPOIAppPOIsRelationships.self, from: data))
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
