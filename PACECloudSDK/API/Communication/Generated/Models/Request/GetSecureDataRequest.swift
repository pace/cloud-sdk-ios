//
// Generated by SwiftPoet
// https://github.com/outfoxx/swiftpoet
//
import Foundation

public extension API.Communication {
    /**
     * Retrieve a previously saved string value by key. The user should authenticate the access to the string e.g. with biometric authentication. */
    struct GetSecureDataRequest: Codable {
        /**
         * The key of the requested secure data value. */
        public let key: String
    }
}
