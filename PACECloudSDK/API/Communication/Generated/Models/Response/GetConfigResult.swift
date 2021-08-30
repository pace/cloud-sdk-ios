//
// Generated by SwiftPoet
// https://github.com/outfoxx/swiftpoet
//
import Foundation

public extension API.Communication {
    /**
     * Requests a configuration value which was defined externally (e.g. via Firebase).
     * Note that the value will always be returned as a string, regardless of the actual type.
     */
    struct GetConfigResponse: Codable {
        /**
         * The configuration value for the corresponding key, if found */
        public let value: String

        public init(value: String) {
            self.value = value
        }
    }
}

extension API.Communication {
    class GetConfigError: Error {}

    class GetConfigResult: Result {
        init(_ success: Success) {
            super.init(status: 200, body: .init(success.response))
        }

        init(_ failure: Failure) {
            super.init(status: failure.statusCode.rawValue, body: .init(failure.response))
        }

        struct Success {
            let response: GetConfigResponse
        }

        struct Failure {
            let statusCode: StatusCode
            let response: GetConfigError

            enum StatusCode: Int {
                case badRequest = 400
                case notFound = 404
                case requestTimeout = 408
                case internalServerError = 500
            }
        }
    }
}