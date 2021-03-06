//
// Generated by SwiftPoet
// https://github.com/outfoxx/swiftpoet
//
import Foundation

public extension API.Communication {
    /**
     * The Apple Pay payment request to be handled (iOS only). */
    struct ApplePayRequestResponse: Codable {
        /**
         * Information about the card used in the transaction. */
        public let paymentMethod: PaymentMethod
        /**
         * Information about the payment data. */
        public let paymentData: PaymentData
        /**
         * A string that describes a globally unique identifier for this transaction. */
        public let transactionIdentifier: String

        public init(paymentMethod: PaymentMethod, paymentData: PaymentData, transactionIdentifier: String) {
            self.paymentMethod = paymentMethod
            self.paymentData = paymentData
            self.transactionIdentifier = transactionIdentifier
        }
    }

    struct PaymentData: Codable {
        /**
         * Version information about the payment token. */
        public let version: String
        /**
         * Encrypted payment data. */
        public let data: String
        /**
         * Signature of the payment and header data. */
        public let signature: String
        /**
         * Additional version-dependent information used to decrypt and verify the payment. */
        public let header: Header

        public init(version: String, data: String, signature: String, header: Header) {
            self.version = version
            self.data = data
            self.signature = signature
            self.header = header
        }
    }

    struct Header: Codable {
        /**
         * Ephemeral public key bytes. */
        public let ephemeralPublicKey: String
        /**
         * Hash of the X.509 encoded public key bytes of the merchant’s certificate. */
        public let publicKeyHash: String
        /**
         * Transaction identifier, generated on the device. */
        public let transactionId: String

        public init(ephemeralPublicKey: String, publicKeyHash: String, transactionId: String) {
            self.ephemeralPublicKey = ephemeralPublicKey
            self.publicKeyHash = publicKeyHash
            self.transactionId = transactionId
        }
    }

    struct PaymentMethod: Codable {
        /**
         * The name of the payment method. */
        public let displayName: String?
        /**
         * The corresponding payment network of the payment method. */
        public let network: String?
        /**
         * The type of the payment method. */
        public let type: String

        public init(displayName: String?, network: String?, type: String) {
            self.displayName = displayName
            self.network = network
            self.type = type
        }
    }
}

extension API.Communication {
    class ApplePayRequestError: Error {}

    class ApplePayRequestResult: Result {
        init(_ success: Success) {
            super.init(status: 200, body: .init(success.response))
        }

        init(_ failure: Failure) {
            super.init(status: failure.statusCode.rawValue, body: .init(failure.response))
        }

        struct Success {
            let response: ApplePayRequestResponse
        }

        struct Failure {
            let statusCode: StatusCode
            let response: ApplePayRequestError

            enum StatusCode: Int {
                case badRequest = 400
                case requestTimeout = 408
                case internalServerError = 500
            }
        }
    }
}
