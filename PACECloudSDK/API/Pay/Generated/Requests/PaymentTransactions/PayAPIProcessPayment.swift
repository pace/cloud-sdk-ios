//
// Generated by SwagGen
// https://github.com/pace/SwagGen
//

import Foundation

extension PayAPI.PaymentTransactions {

    /**
    Process payment

    Process payment and notify user (payment receipt) if transaction is finished successfully.
The `priceIncludingVAT` and `currency` attributes are required, unless when announcing a transaction in which case those values are copied from the token and any given values are ignored.
<br><br>
Only use after approaching (fueling api), otherwise returns `403 Forbidden`.
    */
    public enum ProcessPayment {

        public static var service = PayAPIService<Response>(id: "ProcessPayment", tag: "Payment Transactions", method: "POST", path: "/transactions", hasBody: true, securityRequirements: [SecurityRequirement(type: "OAuth2", scopes: ["pay:transactions:create"]), SecurityRequirement(type: "OIDC", scopes: ["pay:transactions:create"])])

        public final class Request: PayAPIRequest<Response> {

            /** Process payment and notify user (payment receipt) if transaction is finished successfully.
            The `priceIncludingVAT` and `currency` attributes are required, unless when announcing a transaction in which case those values are copied from the token and any given values are ignored.
            <br><br>
            Only use after approaching (fueling api), otherwise returns `403 Forbidden`.
             */
            public class Body: APIModel {

                public var data: PCPayTransactionCreate?

                public init(data: PCPayTransactionCreate? = nil) {
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

                /** Announcing the transaction without actually capturing the payment. An announced transaction can later be processed only if providing the same `paymentToken`, `purposePRN`, and `providerPRN`. By announcing the transaction the token is locked to be used only with this transaction. The `priceIncludingVAT` and `currency` will be taken from the token, and upon capturing the transaction, must be equal or lower than what was announced. */
                public var announce: Bool?

                public init(announce: Bool? = nil) {
                    self.announce = announce
                }
            }

            public var options: Options

            public var body: Body

            public init(body: Body, options: Options, encoder: RequestEncoder? = nil) {
                self.body = body
                self.options = options
                super.init(service: ProcessPayment.service) { defaultEncoder in
                    return try (encoder ?? defaultEncoder).encode(body)
                }
            }

            /// convenience initialiser so an Option doesn't have to be created
            public convenience init(announce: Bool? = nil, body: Body) {
                let options = Options(announce: announce)
                self.init(body: body, options: options)
            }

            public override var queryParameters: [String: Any] {
                var params: [String: Any] = [:]
                if let announce = options.announce {
                  params["announce"] = announce
                }
                return params
            }
        }

        public enum Response: APIResponseValue, CustomStringConvertible, CustomDebugStringConvertible {

            /** Process payment and notify user (payment receipt) if transaction is finished successfully.
            The `priceIncludingVAT` and `currency` attributes are required, unless when announcing a transaction in which case those values are copied from the token and any given values are ignored.
            <br><br>
            Only use after approaching (fueling api), otherwise returns `403 Forbidden`.
             */
            public class Status201: APIModel {

                public var data: PCPayTransaction?

                public init(data: PCPayTransaction? = nil) {
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
                  guard let object = object as? Status201 else { return false }
                  guard self.data == object.data else { return false }
                  return true
                }

                public static func == (lhs: Status201, rhs: Status201) -> Bool {
                    return lhs.isEqual(to: rhs)
                }
            }
            public typealias SuccessType = Status201

            /** Created */
            case status201(Status201)

            /** Bad request */
            case status400(PCPayErrors)

            /** OAuth token missing or invalid */
            case status401(PCPayErrors)

            /** Forbidden */
            case status403(PCPayErrors)

            /** Resource not found */
            case status404(PCPayErrors)

            /** The specified accept header is invalid */
            case status406(PCPayErrors)

            /** Resource conflicts */
            case status409(PCPayErrors)

            /** The specified content type header is invalid */
            case status415(PCPayErrors)

            /** The request was well-formed but was unable to be followed due to semantic errors. */
            case status422(PCPayErrors)

            /** Internal server error */
            case status500(PCPayErrors)

            /** Error occurred while communicating with upstream services */
            case status502(PCPayErrors)

            public var success: Status201? {
                switch self {
                case .status201(let response): return response
                default: return nil
                }
            }

            public var failure: PCPayErrors? {
                switch self {
                case .status400(let response): return response
                case .status401(let response): return response
                case .status403(let response): return response
                case .status404(let response): return response
                case .status406(let response): return response
                case .status409(let response): return response
                case .status415(let response): return response
                case .status422(let response): return response
                case .status500(let response): return response
                case .status502(let response): return response
                default: return nil
                }
            }

            /// either success or failure value. Success is anything in the 200..<300 status code range
            public var responseResult: APIResponseResult<Status201, PCPayErrors> {
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
                case .status201(let response): return response
                case .status400(let response): return response
                case .status401(let response): return response
                case .status403(let response): return response
                case .status404(let response): return response
                case .status406(let response): return response
                case .status409(let response): return response
                case .status415(let response): return response
                case .status422(let response): return response
                case .status500(let response): return response
                case .status502(let response): return response
                }
            }

            public var statusCode: Int {
                switch self {
                case .status201: return 201
                case .status400: return 400
                case .status401: return 401
                case .status403: return 403
                case .status404: return 404
                case .status406: return 406
                case .status409: return 409
                case .status415: return 415
                case .status422: return 422
                case .status500: return 500
                case .status502: return 502
                }
            }

            public var successful: Bool {
                switch self {
                case .status201: return true
                case .status400: return false
                case .status401: return false
                case .status403: return false
                case .status404: return false
                case .status406: return false
                case .status409: return false
                case .status415: return false
                case .status422: return false
                case .status500: return false
                case .status502: return false
                }
            }

            public init(statusCode: Int, data: Data, decoder: ResponseDecoder) throws {
                switch statusCode {
                case 201: self = try .status201(decoder.decode(Status201.self, from: data))
                case 400: self = try .status400(decoder.decode(PCPayErrors.self, from: data))
                case 401: self = try .status401(decoder.decode(PCPayErrors.self, from: data))
                case 403: self = try .status403(decoder.decode(PCPayErrors.self, from: data))
                case 404: self = try .status404(decoder.decode(PCPayErrors.self, from: data))
                case 406: self = try .status406(decoder.decode(PCPayErrors.self, from: data))
                case 409: self = try .status409(decoder.decode(PCPayErrors.self, from: data))
                case 415: self = try .status415(decoder.decode(PCPayErrors.self, from: data))
                case 422: self = try .status422(decoder.decode(PCPayErrors.self, from: data))
                case 500: self = try .status500(decoder.decode(PCPayErrors.self, from: data))
                case 502: self = try .status502(decoder.decode(PCPayErrors.self, from: data))
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
