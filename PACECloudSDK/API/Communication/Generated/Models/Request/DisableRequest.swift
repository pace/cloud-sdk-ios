//
// Generated by SwiftPoet
// https://github.com/outfoxx/swiftpoet
//
import Foundation

public extension API.Communication {
    /**
     * The current app will no longer be displayed up until the given date. */
    struct DisableRequest: Codable {
        /**
         * The date when the app should be enabled again, in seconds since epoch */
        public let until: Double
    }
}
