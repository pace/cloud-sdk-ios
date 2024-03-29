//
// Generated by SwiftPoet
// https://github.com/outfoxx/swiftpoet
//
import Foundation

extension API.Communication {
    class ShareTextError: Error {}

    class ShareTextResult: Result {
        init(_ success: Success) {
            super.init(status: 200, body: nil)
        }

        init(_ failure: Failure) {
            super.init(status: failure.statusCode.rawValue, body: .init(failure.response))
        }

        struct Success {}

        struct Failure {
            let statusCode: StatusCode
            let response: ShareTextError

            enum StatusCode: Int {
                case badRequest = 400
                case methodNotAllowed = 405
                case requestTimeout = 408
                case internalServerError = 500
            }
        }
    }
}
