//
// Generated by SwiftPoet
// https://github.com/outfoxx/swiftpoet
//
import Foundation

public extension API.Communication {
    /**
     * Requests to save a string securely on the device for later retrieval. */
    struct SetSecureDataRequest: Codable {
        /**
         * The key under which the secure data should be stored. */
        public let key: String
        /**
         * The secure value to be stored. */
        public let value: String
    }
}