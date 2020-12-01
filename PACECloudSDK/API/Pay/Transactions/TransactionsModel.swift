//
//  TransactionsModel.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

public extension API.Pay {
    struct TransactionsResponse: Decodable {
        public let data: [Transaction]
    }

    struct Transaction: Decodable {
        public let type: String?
        public let id: String?
        public let attributes: TransactionAttributes?
        public let links: TransactionLinks?
    }

    struct TransactionAttributes: Decodable {
        public let vat: TransactionVAT?
        public let createdAt: String?
        public let currency: String?
        public let fuel: TransactionFuel?
        public let location: TransactionLocation?
        public let paymentMethodId: String?
        public let paymentMethodKind: String?
        public let paymentToken: String?
        public let priceIncludingVAT: Double?
        public let priceWithoutVAT: Double?
        public let providerPRN: String?
        public let purposePRN: String?
        public let updatedAt: String?

        enum CodingKeys: String, CodingKey { // swiftlint:disable:this nesting
            case vat = "VAT"
            case createdAt, currency, fuel, location, paymentMethodId,
                 paymentMethodKind, paymentToken, priceIncludingVAT,
                 priceWithoutVAT, providerPRN, purposePRN, updatedAt
        }
    }

    struct TransactionVAT: Decodable {
        public let amount: Double?
        public let rate: Double?
    }

    struct TransactionFuel: Decodable {
        public let amount: Double?
        public let pricePerUnit: Double?
        public let productName: String?
        public let pumpNumber: Int?
    }

    struct TransactionLocation: Decodable {
        public let address: TransactionAddress?
        public let brand: String?
        public let latitude: Double?
        public let longitude: Double?
    }

    // MARK: - Address
    struct TransactionAddress: Decodable {
        public let city: String?
        public let countryCode: String?
        public let houseNo: String?
        public let postalCode: String?
        public let street: String?
    }

    struct TransactionLinks: Decodable {
        public let receipt: TransactionReceipt?
        public let receiptPDF: TransactionReceipt?
    }

    struct TransactionReceipt: Decodable {
        public let href: String?
        public let meta: TransactionMeta?
    }

    struct TransactionMeta: Decodable {
        public let mimeType: TransactionMIMEType?
    }

    enum TransactionMIMEType: String, Decodable {
        case applicationPDF = "application/pdf"
        case imagePNG = "image/png"
    }
}
