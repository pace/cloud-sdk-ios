//
// Generated by SwagGen
// https://github.com/pace/SwagGen
//

import Foundation

extension POIAPI.Apps {

    /** Deletes App with specified id */
    public enum DeleteApp {

        public static var service = POIAPIService<Response>(id: "DeleteApp", tag: "Apps", method: "DELETE", path: "/apps/{appID}", hasBody: false, securityRequirements: [SecurityRequirement(type: "OAuth2", scopes: ["poi:apps:delete"]), SecurityRequirement(type: "OIDC", scopes: ["poi:apps:delete"])])

        public final class Request: POIAPIRequest<Response> {

            public struct Options {

                /** ID of the App */
                public var appID: ID?

                public init(appID: ID? = nil) {
                    self.appID = appID
                }
            }

            public var options: Options

            public init(options: Options) {
                self.options = options
                super.init(service: DeleteApp.service)
            }

            /// convenience initialiser so an Option doesn't have to be created
            public convenience init(appID: ID? = nil) {
                let options = Options(appID: appID)
                self.init(options: options)
            }

            public override var path: String {
                return super.path.replacingOccurrences(of: "{" + "appID" + "}", with: "\(self.options.appID?.encode() ?? "")")
            }
        }

        public enum Response: APIResponseValue, CustomStringConvertible, CustomDebugStringConvertible {
            public typealias SuccessType = Void

            /** OK */
            case status204

            /** OAuth token missing or invalid */
            case status401(PCPOIErrors)

            /** Resource not found */
            case status404(PCPOIErrors)

            /** The specified accept header is invalid */
            case status406(PCPOIErrors)

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
                case .status401(let response): return response
                case .status404(let response): return response
                case .status406(let response): return response
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
                case .status401(let response): return response
                case .status404(let response): return response
                case .status406(let response): return response
                case .status500(let response): return response
                default: return ()
                }
            }

            public var statusCode: Int {
                switch self {
                case .status204: return 204
                case .status401: return 401
                case .status404: return 404
                case .status406: return 406
                case .status500: return 500
                }
            }

            public var successful: Bool {
                switch self {
                case .status204: return true
                case .status401: return false
                case .status404: return false
                case .status406: return false
                case .status500: return false
                }
            }

            public init(statusCode: Int, data: Data, decoder: ResponseDecoder) throws {
                switch statusCode {
                case 204: self = .status204
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
