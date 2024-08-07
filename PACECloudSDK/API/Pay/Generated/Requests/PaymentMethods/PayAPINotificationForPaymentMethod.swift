//
// Generated by SwagGen
// https://github.com/pace/SwagGen
//

import Foundation

extension PayAPI.PaymentMethods {

    /** Notify about payment method data */
    public enum NotificationForPaymentMethod {

        public static var service = PayAPIService<Response>(id: "NotificationForPaymentMethod", tag: "Payment Methods", method: "POST", path: "/payment-methods/{paymentMethodId}/notification", hasBody: false, securityRequirements: [])

        public final class Request: PayAPIRequest<Response> {

            public struct Options {

                /** Type of the notification */
                public var type: String?

                /** ID of the paymentMethod */
                public var paymentMethodId: ID

                public init(type: String? = nil, paymentMethodId: ID) {
                    self.type = type
                    self.paymentMethodId = paymentMethodId
                }
            }

            public var options: Options

            public init(options: Options) {
                self.options = options
                super.init(service: NotificationForPaymentMethod.service)
            }

            /// convenience initialiser so an Option doesn't have to be created
            public convenience init(type: String? = nil, paymentMethodId: ID) {
                let options = Options(type: type, paymentMethodId: paymentMethodId)
                self.init(options: options)
            }

            public override var path: String {
                return super.path.replacingOccurrences(of: "{" + "paymentMethodId" + "}", with: "\(self.options.paymentMethodId.encode())")
            }

            public override var queryParameters: [String: Any] {
                var params: [String: Any] = [:]
                if let type = options.type {
                  params["type"] = type
                }
                return params
            }

            public override var isAuthorizationRequired: Bool {
                false
            }
        }

        public enum Response: APIResponseValue, CustomStringConvertible, CustomDebugStringConvertible {
            public typealias SuccessType = Void

            /** Notification received */
            case status200

            public var success: Void? {
                switch self {
                case .status200: return ()
                }
            }

            public var response: Any {
                switch self {
                default: return ()
                }
            }

            public var statusCode: Int {
                switch self {
                case .status200: return 200
                }
            }

            public var successful: Bool {
                switch self {
                case .status200: return true
                }
            }

            public init(statusCode: Int, data: Data, decoder: ResponseDecoder) throws {
                switch statusCode {
                case 200: self = .status200
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
