//
// Generated by SwiftPoet
// https://github.com/outfoxx/swiftpoet
//
import Foundation

public extension API.Communication {
    /**
     * Requests a fresh access token for the currently authenticated user. */
    struct GetAccessTokenRequest: Codable {
        /**
         * The reason for requesting a new access token. Currently the value can either be `unauthorized` or `other`. */
        public let reason: String
        /**
         * The token which was used before by the app. */
        public let oldToken: String?
    }
}
