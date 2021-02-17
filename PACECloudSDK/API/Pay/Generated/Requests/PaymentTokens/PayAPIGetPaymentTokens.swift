//
// Generated by SwagGen
// https://github.com/pace/SwagGen
//

import Foundation

extension PayAPI.PaymentTokens {

    /**
    Get all valid payment tokens for user

    Get all valid payment tokens for user. Valid means that a token was successfully created and is not expired. It might be unusable, for example if it is used in a transaction already.
    */
    public enum GetPaymentTokens {

        public static var service = PayAPIService<Response>(id: "GetPaymentTokens", tag: "Payment Tokens", method: "GET", path: "/payment-tokens", hasBody: false, securityRequirements: [SecurityRequirement(type: "OAuth2", scopes: ["pay:payment-tokens:read"]), SecurityRequirement(type: "OIDC", scopes: ["pay:payment-tokens:read"])])

        /** Get all valid payment tokens for user. Valid means that a token was successfully created and is not expired. It might be unusable, for example if it is used in a transaction already. */
        public enum PCPayFiltervalid: String, Codable, Equatable, CaseIterable {
            case `true` = "true"
        }

        public final class Request: PayAPIRequest<Response> {

            public struct Options {

                public var filtervalid: PCPayFiltervalid

                public init(filtervalid: PCPayFiltervalid) {
                    self.filtervalid = filtervalid
                }
            }

            public var options: Options

            public init(options: Options) {
                self.options = options
                super.init(service: GetPaymentTokens.service)
            }

            /// convenience initialiser so an Option doesn't have to be created
            public convenience init(filtervalid: PCPayFiltervalid) {
                let options = Options(filtervalid: filtervalid)
                self.init(options: options)
            }

            public override var queryParameters: [String: Any] {
                var params: [String: Any] = [:]
                params["filter[valid]"] = options.filtervalid.encode()
                return params
            }
        }

        public enum Response: APIResponseValue, CustomStringConvertible, CustomDebugStringConvertible {

            /** Get all valid payment tokens for user. Valid means that a token was successfully created and is not expired. It might be unusable, for example if it is used in a transaction already. */
            public class Status200: APIModel {

                public var data: PCPayPaymentTokens?

                public init(data: PCPayPaymentTokens? = nil) {
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

            /** All valid payment tokens. */
            case status200(Status200)

            /** OAuth token missing or invalid */
            case status401(PCPayErrors)

            /** Internal server error */
            case status500(PCPayErrors)

            public var success: Status200? {
                switch self {
                case .status200(let response): return response
                default: return nil
                }
            }

            public var failure: PCPayErrors? {
                switch self {
                case .status401(let response): return response
                case .status500(let response): return response
                default: return nil
                }
            }

            /// either success or failure value. Success is anything in the 200..<300 status code range
            public var responseResult: APIResponseResult<Status200, PCPayErrors> {
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
                case .status500(let response): return response
                }
            }

            public var statusCode: Int {
                switch self {
                case .status200: return 200
                case .status401: return 401
                case .status500: return 500
                }
            }

            public var successful: Bool {
                switch self {
                case .status200: return true
                case .status401: return false
                case .status500: return false
                }
            }

            public init(statusCode: Int, data: Data, decoder: ResponseDecoder) throws {
                switch statusCode {
                case 200: self = try .status200(decoder.decode(Status200.self, from: data))
                case 401: self = try .status401(decoder.decode(PCPayErrors.self, from: data))
                case 500: self = try .status500(decoder.decode(PCPayErrors.self, from: data))
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