//
// Generated by SwiftPoet
// https://github.com/outfoxx/swiftpoet
//
import Foundation

public extension API.Communication {
    /**
     * Asks the client for an optional additional receipt email. */
    struct ReceiptEmailResponse: Codable {
        /**
         * The email */
        public let email: String?

        public init(email: String?) {
            self.email = email
        }
    }
}

extension API.Communication {
    class ReceiptEmailError: Error {}

    class ReceiptEmailResult: Result {
        init(_ success: Success) {
            super.init(status: 200, body: .init(success.response))
        }

        init(_ failure: Failure) {
            super.init(status: failure.statusCode.rawValue, body: .init(failure.response))
        }

        struct Success {
            let response: ReceiptEmailResponse
        }

        struct Failure {
            let statusCode: StatusCode
            let response: ReceiptEmailError

            enum StatusCode: Int {
                case badRequest = 400
                case requestTimeout = 408
                case internalServerError = 500
            }
        }
    }
}
