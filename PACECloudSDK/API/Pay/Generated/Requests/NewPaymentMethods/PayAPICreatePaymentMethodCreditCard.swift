//
// Generated by SwagGen
// https://github.com/pace/SwagGen
//

import Foundation

extension PayAPI.NewPaymentMethods {

    /**
    Register a CreditCard as a payment method

    By registering you allow the user to use a CreditCard as a payment method.
The payment method ID is optional when posting data.
    */
    public enum CreatePaymentMethodCreditCard {

        public static var service = PayAPIService<Response>(id: "CreatePaymentMethodCreditCard", tag: "New Payment Methods", method: "POST", path: "/payment-methods/creditcard", hasBody: true, securityRequirements: [SecurityRequirement(type: "OAuth2", scopes: ["pay:payment-methods:create"]), SecurityRequirement(type: "OIDC", scopes: ["pay:payment-methods:create"])])

        public final class Request: PayAPIRequest<Response> {

            /** By registering you allow the user to use a CreditCard as a payment method.
            The payment method ID is optional when posting data.
             */
            public class Body: APIModel {

                public var data: PCPayPaymentMethodCreditCardCreate?

                public init(data: PCPayPaymentMethodCreditCardCreate? = nil) {
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
                super.init(service: CreatePaymentMethodCreditCard.service) { defaultEncoder in
                    return try (encoder ?? defaultEncoder).encode(body)
                }
            }
        }

        public enum Response: APIResponseValue, CustomStringConvertible, CustomDebugStringConvertible {

            /** By registering you allow the user to use a CreditCard as a payment method.
            The payment method ID is optional when posting data.
             */
            public class Status201: APIModel {

                public var data: PCPayPaymentMethod?

                public init(data: PCPayPaymentMethod? = nil) {
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

            /** Already exists */
            case status303

            /** Bad request */
            case status400(PCPayErrors)

            /** OAuth token missing or invalid */
            case status401(PCPayErrors)

            /** The specified accept header is invalid */
            case status406(PCPayErrors)

            /** Resource conflicts */
            case status409(PCPayErrors)

            /** The specified content type header is invalid */
            case status415(PCPayErrors)

            /** The request was well-formed but was unable to be followed due to semantic errors. The following codes may be seen:
* `provider:card-not-usable`: The card is rejected by the payment provider, e.g., credit card expired
* `provider:invalid-content`: One or more fields of the payment method is not accepted by the payment provider, e.g., wrong checksum (CVC)
* `invalid-charset`: The fields charset is not latin
* `too-long`: The fields content is too long
Errors also contain codes besides title and message which can be used for checks even if the detailed messages might change.
* code `1000`:  generic error
* code `1001`:  payment processing temporarily unavailable
* code `1002`:  requested amount exceeds the authorized amount of the provided token
* code `1003`:  implicit payment methods cannot be modified
* code `1004`:  payment method rejected by provider
 */
            case status422(PCPayErrors)

            /** Internal server error */
            case status500(PCPayErrors)

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
                case .status406(let response): return response
                case .status409(let response): return response
                case .status415(let response): return response
                case .status422(let response): return response
                case .status500(let response): return response
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
                case .status406(let response): return response
                case .status409(let response): return response
                case .status415(let response): return response
                case .status422(let response): return response
                case .status500(let response): return response
                default: return ()
                }
            }

            public var statusCode: Int {
                switch self {
                case .status201: return 201
                case .status303: return 303
                case .status400: return 400
                case .status401: return 401
                case .status406: return 406
                case .status409: return 409
                case .status415: return 415
                case .status422: return 422
                case .status500: return 500
                }
            }

            public var successful: Bool {
                switch self {
                case .status201: return true
                case .status303: return false
                case .status400: return false
                case .status401: return false
                case .status406: return false
                case .status409: return false
                case .status415: return false
                case .status422: return false
                case .status500: return false
                }
            }

            public init(statusCode: Int, data: Data, decoder: ResponseDecoder) throws {
                switch statusCode {
                case 201: self = try .status201(decoder.decode(Status201.self, from: data))
                case 303: self = .status303
                case 400: self = try .status400(decoder.decode(PCPayErrors.self, from: data))
                case 401: self = try .status401(decoder.decode(PCPayErrors.self, from: data))
                case 406: self = try .status406(decoder.decode(PCPayErrors.self, from: data))
                case 409: self = try .status409(decoder.decode(PCPayErrors.self, from: data))
                case 415: self = try .status415(decoder.decode(PCPayErrors.self, from: data))
                case 422: self = try .status422(decoder.decode(PCPayErrors.self, from: data))
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
