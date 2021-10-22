//
// Generated by SwagGen
// https://github.com/pace/SwagGen
//

import Foundation

public class PCFuelingTransaction: APIModel {

    public enum PCFuelingType: String, Codable, Equatable, CaseIterable {
        case transaction = "transaction"
    }

    public var attributes: Attributes?

    /** Transaction ID */
    public var id: ID?

    public var type: PCFuelingType?

    public class Attributes: APIModel {

        public var vat: VAT?

        public var authorizedAmount: Decimal?

        /** Currency as specified in ISO-4217. */
        public var currency: String?

        public var fuelAmount: Decimal?

        public var fuelType: String?

        public var paymentToken: String?

        public var priceIncludingVAT: Decimal?

        public var pricePerUnit: Decimal?

        public var priceWithoutVAT: Decimal?

        public var productName: String?

        public var status: String?

        public class VAT: APIModel {

            public var amount: Decimal?

            public var rate: Decimal?

            public init(amount: Decimal? = nil, rate: Decimal? = nil) {
                self.amount = amount
                self.rate = rate
            }

            public required init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: StringCodingKey.self)

                amount = try container.decodeIfPresent("amount")
                rate = try container.decodeIfPresent("rate")
            }

            public func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: StringCodingKey.self)

                try container.encodeIfPresent(amount, forKey: "amount")
                try container.encodeIfPresent(rate, forKey: "rate")
            }

            public func isEqual(to object: Any?) -> Bool {
              guard let object = object as? VAT else { return false }
              guard self.amount == object.amount else { return false }
              guard self.rate == object.rate else { return false }
              return true
            }

            public static func == (lhs: VAT, rhs: VAT) -> Bool {
                return lhs.isEqual(to: rhs)
            }
        }

        public init(vat: VAT? = nil, authorizedAmount: Decimal? = nil, currency: String? = nil, fuelAmount: Decimal? = nil, fuelType: String? = nil, paymentToken: String? = nil, priceIncludingVAT: Decimal? = nil, pricePerUnit: Decimal? = nil, priceWithoutVAT: Decimal? = nil, productName: String? = nil, status: String? = nil) {
            self.vat = vat
            self.authorizedAmount = authorizedAmount
            self.currency = currency
            self.fuelAmount = fuelAmount
            self.fuelType = fuelType
            self.paymentToken = paymentToken
            self.priceIncludingVAT = priceIncludingVAT
            self.pricePerUnit = pricePerUnit
            self.priceWithoutVAT = priceWithoutVAT
            self.productName = productName
            self.status = status
        }

        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: StringCodingKey.self)

            vat = try container.decodeIfPresent("VAT")
            authorizedAmount = try container.decodeIfPresent("authorizedAmount")
            currency = try container.decodeIfPresent("currency")
            fuelAmount = try container.decodeIfPresent("fuelAmount")
            fuelType = try container.decodeIfPresent("fuelType")
            paymentToken = try container.decodeIfPresent("paymentToken")
            priceIncludingVAT = try container.decodeIfPresent("priceIncludingVAT")
            pricePerUnit = try container.decodeIfPresent("pricePerUnit")
            priceWithoutVAT = try container.decodeIfPresent("priceWithoutVAT")
            productName = try container.decodeIfPresent("productName")
            status = try container.decodeIfPresent("status")
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: StringCodingKey.self)

            try container.encodeIfPresent(vat, forKey: "VAT")
            try container.encodeIfPresent(authorizedAmount, forKey: "authorizedAmount")
            try container.encodeIfPresent(currency, forKey: "currency")
            try container.encodeIfPresent(fuelAmount, forKey: "fuelAmount")
            try container.encodeIfPresent(fuelType, forKey: "fuelType")
            try container.encodeIfPresent(paymentToken, forKey: "paymentToken")
            try container.encodeIfPresent(priceIncludingVAT, forKey: "priceIncludingVAT")
            try container.encodeIfPresent(pricePerUnit, forKey: "pricePerUnit")
            try container.encodeIfPresent(priceWithoutVAT, forKey: "priceWithoutVAT")
            try container.encodeIfPresent(productName, forKey: "productName")
            try container.encodeIfPresent(status, forKey: "status")
        }

        public func isEqual(to object: Any?) -> Bool {
          guard let object = object as? Attributes else { return false }
          guard self.vat == object.vat else { return false }
          guard self.authorizedAmount == object.authorizedAmount else { return false }
          guard self.currency == object.currency else { return false }
          guard self.fuelAmount == object.fuelAmount else { return false }
          guard self.fuelType == object.fuelType else { return false }
          guard self.paymentToken == object.paymentToken else { return false }
          guard self.priceIncludingVAT == object.priceIncludingVAT else { return false }
          guard self.pricePerUnit == object.pricePerUnit else { return false }
          guard self.priceWithoutVAT == object.priceWithoutVAT else { return false }
          guard self.productName == object.productName else { return false }
          guard self.status == object.status else { return false }
          return true
        }

        public static func == (lhs: Attributes, rhs: Attributes) -> Bool {
            return lhs.isEqual(to: rhs)
        }
    }

    public init(attributes: Attributes? = nil, id: ID? = nil, type: PCFuelingType? = nil) {
        self.attributes = attributes
        self.id = id
        self.type = type
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StringCodingKey.self)

        attributes = try container.decodeIfPresent("attributes")
        id = try container.decodeIfPresent("id")
        type = try container.decodeIfPresent("type")
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StringCodingKey.self)

        try container.encodeIfPresent(attributes, forKey: "attributes")
        try container.encodeIfPresent(id, forKey: "id")
        try container.encodeIfPresent(type, forKey: "type")
    }

    public func isEqual(to object: Any?) -> Bool {
      guard let object = object as? PCFuelingTransaction else { return false }
      guard self.attributes == object.attributes else { return false }
      guard self.id == object.id else { return false }
      guard self.type == object.type else { return false }
      return true
    }

    public static func == (lhs: PCFuelingTransaction, rhs: PCFuelingTransaction) -> Bool {
        return lhs.isEqual(to: rhs)
    }
}
