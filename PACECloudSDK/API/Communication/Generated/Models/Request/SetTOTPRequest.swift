//
// Generated by SwiftPoet
// https://github.com/outfoxx/swiftpoet
//
import Foundation

public extension API.Communication {
    /**
     * Requests to save TOTP secret data on the device for later retrieval. */
    struct SetTOTPRequest: Codable {
        /**
         * A Base 32 encoded string. */
        public let secret: String
        /**
         * The time in seconds a generated TOTP hash is valid for. */
        public let period: Int
        /**
         * The required length of the generated TOTP. */
        public let digits: Int
        /**
         * Algorithm to use for HMAC, accepted values: `SHA1`, `SHA256`, `SHA512`. */
        public let algorithm: String
        /**
         * The key under which the TOTP secret data should be stored. */
        public let key: String
    }
}
