//
// Generated by SwagGen
// https://github.com/pace/SwagGen
//

import Foundation

extension PayAPI.PaymentMethods {

    /**
    Confirm and redirect to frontend

    Redirect endpoint to confirm a payment method. External services redirect the user here and in turn this endpoint redirects the user to the frontend.
    */
    public enum ConfirmPaymentMethod {

        public static var service = PayAPIService<Response>(id: "ConfirmPaymentMethod", tag: "Payment Methods", method: "GET", path: "/payment-methods/confirm/{token}", hasBody: false, securityRequirements: [])

        public final class Request: PayAPIRequest<Response> {

            public struct Options {

                /** single use token */
                public var token: String

                public init(token: String) {
                    self.token = token
                }
            }

            public var options: Options

            public init(options: Options) {
                self.options = options
                super.init(service: ConfirmPaymentMethod.service)
            }

            /// convenience initialiser so an Option doesn't have to be created
            public convenience init(token: String) {
                let options = Options(token: token)
                self.init(options: options)
            }

            public override var path: String {
                return super.path.replacingOccurrences(of: "{" + "token" + "}", with: "\(self.options.token)")
            }
        }

        public enum Response: APIResponseValue, CustomStringConvertible, CustomDebugStringConvertible {
            public typealias SuccessType = Void

            /** Goto frontend */
            case status303

            /** Resource not found */
            case status404(PCPayErrors)

            /** Internal server error */
            case status500(PCPayErrors)

            public var success: Void? {
                switch self {
                default: return nil
                }
            }

            public var failure: PCPayErrors? {
                switch self {
                case .status404(let response): return response
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
                case .status404(let response): return response
                case .status500(let response): return response
                default: return ()
                }
            }

            public var statusCode: Int {
                switch self {
                case .status303: return 303
                case .status404: return 404
                case .status500: return 500
                }
            }

            public var successful: Bool {
                switch self {
                case .status303: return false
                case .status404: return false
                case .status500: return false
                }
            }

            public init(statusCode: Int, data: Data, decoder: ResponseDecoder) throws {
                switch statusCode {
                case 303: self = .status303
                case 404: self = try .status404(decoder.decode(PCPayErrors.self, from: data))
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