//
//  ApplePayResponse.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation
import PassKit

public extension AppKit {
    struct ApplePayResponse: Codable {
        public let paymentMethod: ApplePayPaymentMethod
        public let paymentData: ApplePayPaymentData
        public let transactionIdentifier: String

        public init(method: ApplePayPaymentMethod, data: ApplePayPaymentData, transactionId: String) {
            paymentMethod = method
            paymentData = data
            transactionIdentifier = transactionId
        }
    }

    struct ApplePayPaymentMethod: Codable {
        public let displayName: String?
        public let network: String?
        public let type: String

        public init(displayName: String?, network: String?, type: PKPaymentMethodType) {
            self.displayName = displayName
            self.network = network
            self.type = {
                switch type {
                case .credit:
                    return "credit"

                case .debit:
                    return "debit"

                case .prepaid:
                    return "prepaid"

                case .store:
                    return "store"

                case .unknown:
                    return "unknown"

                @unknown default:
                    return "undefined"
                }
            }()
        }
    }

    struct ApplePayPaymentData: Codable {
        public let version: String
        public let data: String
        public let signature: String
        public let header: ApplePayPaymentDataHeader

        public init(version: String, data: String, signature: String, header: ApplePayPaymentDataHeader) {
            self.version = version
            self.data = data
            self.signature = signature
            self.header = header
        }
    }

    struct ApplePayPaymentDataHeader: Codable {
        public let ephemeralPublicKey: String
        public let publicKeyHash: String
        public let transactionId: String

        public init(ephemeralPublicKey: String, publicKeyHash: String, transactionId: String) {
            self.ephemeralPublicKey = ephemeralPublicKey
            self.publicKeyHash = publicKeyHash
            self.transactionId = transactionId
        }
    }
}
