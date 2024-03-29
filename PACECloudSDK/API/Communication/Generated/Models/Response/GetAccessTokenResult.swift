//
// Generated by SwiftPoet
// https://github.com/outfoxx/swiftpoet
//
import Foundation

public extension API.Communication {
    /**
     * Requests a fresh access token for the currently authenticated user. */
    struct GetAccessTokenResponse: Codable {
        /**
         * The newly retrieved access token */
        public let accessToken: String
        public let isInitialToken: Bool?

        public init(accessToken: String, isInitialToken: Bool?) {
            self.accessToken = accessToken
            self.isInitialToken = isInitialToken
        }
    }
}

extension API.Communication {
    class GetAccessTokenError: Error {}

    class GetAccessTokenResult: Result {
        init(_ success: Success) {
            super.init(status: 200, body: .init(success.response))
        }

        init(_ failure: Failure) {
            super.init(status: failure.statusCode.rawValue, body: .init(failure.response))
        }

        struct Success {
            let response: GetAccessTokenResponse
        }

        struct Failure {
            let statusCode: StatusCode
            let response: GetAccessTokenError

            enum StatusCode: Int {
                case badRequest = 400
                case requestTimeout = 408
                case clientClosedRequest = 499
                case internalServerError = 500
            }
        }
    }
}
