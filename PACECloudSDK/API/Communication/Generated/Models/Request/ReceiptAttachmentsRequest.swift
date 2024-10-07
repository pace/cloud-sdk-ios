//
// Generated by SwiftPoet
// https://github.com/outfoxx/swiftpoet
//
import Foundation

public extension API.Communication {
    /**
     * Asks the client for optional attachments to be included in the fueling receipt. */
    struct ReceiptAttachmentsRequest: Codable {
        /**
         * The id of the user payment method. */
        public let paymentMethod: String
    }
}