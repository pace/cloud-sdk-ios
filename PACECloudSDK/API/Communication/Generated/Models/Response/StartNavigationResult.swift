//
// Generated by SwiftPoet
// https://github.com/outfoxx/swiftpoet
//
import Foundation

extension API.Communication {
    class StartNavigationError: Error {}

    class StartNavigationResult: Result {
        init(_ success: Success) {
            super.init(status: 204, body: nil)
        }

        init(_ failure: Failure) {
            super.init(status: failure.statusCode.rawValue, body: .init(failure.response))
        }

        struct Success {}

        struct Failure {
            let statusCode: StatusCode
            let response: StartNavigationError

            enum StatusCode: Int {
                case badRequest = 400
                case requestTimeout = 408
                case internalServerError = 500
            }
        }
    }
}
