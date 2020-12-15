//
// Generated by SwagGen
// https://github.com/pace/SwagGen
//

import Foundation

extension PayAPI.PaymentMethods {

    /** Delete a payment method */
    public enum DeletePaymentMethod {

        public static var service = PayAPIService<Response>(id: "DeletePaymentMethod", tag: "Payment Methods", method: "DELETE", path: "/payment-methods/{paymentMethodId}", hasBody: false, securityRequirements: [SecurityRequirement(type: "OAuth2", scopes: ["pay:payment-methods:delete"]), SecurityRequirement(type: "OIDC", scopes: ["pay:payment-methods:delete"])])

        public final class Request: PayAPIRequest<Response> {

            public struct Options {

                /** ID of the paymentMethod */
                public var paymentMethodId: ID

                public init(paymentMethodId: ID) {
                    self.paymentMethodId = paymentMethodId
                }
            }

            public var options: Options

            public init(options: Options) {
                self.options = options
                super.init(service: DeletePaymentMethod.service)
            }

            /// convenience initialiser so an Option doesn't have to be created
            public convenience init(paymentMethodId: ID) {
                let options = Options(paymentMethodId: paymentMethodId)
                self.init(options: options)
            }

            public override var path: String {
                return super.path.replacingOccurrences(of: "{" + "paymentMethodId" + "}", with: "\(self.options.paymentMethodId.encode())")
            }
        }

        public enum Response: APIResponseValue, CustomStringConvertible, CustomDebugStringConvertible {
            public typealias SuccessType = Void

            /** The payment method was deleted successfully. */
            case status204

            /** OAuth token missing or invalid */
            case status401(PCPayErrors)

            /** Resource not found */
            case status404(PCPayErrors)

            /** Method not allowed */
            case status405(PCPayErrors)

            /** The specified accept header is invalid */
            case status406(PCPayErrors)

            /** Internal server error */
            case status500(PCPayErrors)

            public var success: Void? {
                switch self {
                case .status204: return ()
                default: return nil
                }
            }

            public var failure: PCPayErrors? {
                switch self {
                case .status401(let response): return response
                case .status404(let response): return response
                case .status405(let response): return response
                case .status406(let response): return response
                case .status500(let response): return response
                default: return nil
                }
            }

            /// either success or failure value. Success is anything in the 200..<300 status code range
            public var responseResult: APIResponseResult<Void, PCPayErrors> {
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
                case .status405(let response): return response
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
                case .status405: return 405
                case .status406: return 406
                case .status500: return 500
                }
            }

            public var successful: Bool {
                switch self {
                case .status204: return true
                case .status401: return false
                case .status404: return false
                case .status405: return false
                case .status406: return false
                case .status500: return false
                }
            }

            public init(statusCode: Int, data: Data, decoder: ResponseDecoder) throws {
                switch statusCode {
                case 204: self = .status204
                case 401: self = try .status401(decoder.decode(PCPayErrors.self, from: data))
                case 404: self = try .status404(decoder.decode(PCPayErrors.self, from: data))
                case 405: self = try .status405(decoder.decode(PCPayErrors.self, from: data))
                case 406: self = try .status406(decoder.decode(PCPayErrors.self, from: data))
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
