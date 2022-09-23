//
// Generated by SwagGen
// https://github.com/pace/SwagGen
//

import Foundation

public class PCPayTransactionCreateRequest: APIModel {

    public enum PCPayType: String, Codable, Equatable, CaseIterable {
        case transaction = "transaction"
    }

    public var type: PCPayType

    public var attributes: Attributes

    /** ID of the new transaction. */
    public var id: ID?

    public class Attributes: APIModel {

        /** Payment token value */
        public var paymentToken: String

        /** PACE resource name - referring to the transaction purpose */
        public var purposePRN: String

        /** PACE resource name - referring to the transaction purpose with provider details */
        public var providerPRN: String

        public var vat: VAT?

        /** Currency as specified in ISO-4217. */
        public var currency: String?

        public var fuel: PCPayFuel?

        /** Fuel amount */
        public var fuelAmount: Decimal?

        /** Product name */
        public var fuelProductName: String?

        /** PACE resource name - referring to the transaction issuer */
        public var issuerPRN: String?

        /** PACE resource name - referring to the transaction's merchant */
        public var merchantPRN: String?

        /** Current mileage in meters */
        public var mileage: Int?

        /** Number plate of the car */
        public var numberPlate: String?

        public var priceExcludingVAT: Decimal?

        public var priceIncludingVAT: Decimal?

        /** The given productFlow (e.g. preAuth, postPay) */
        public var productFlow: String?

        /** Vehicle identification number */
        public var vin: String?

        public class VAT: APIModel {

            public var amount: Decimal?

            /** *Important:* Vat rates have to be between 0.00 and 1.00 and not have a decimal precision beyoned 2, i.e., no rate of 0.119999999
         */
            public var rate: Decimal?

            public init(amount: Decimal? = nil, rate: Decimal? = nil) {
                self.amount = amount
                self.rate = rate
            }

            public required init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: StringCodingKey.self)

                amount = try container.decodeLosslessDecimal("amount")
                rate = try container.decodeLosslessDecimal("rate")
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

        public init(paymentToken: String, purposePRN: String, providerPRN: String, vat: VAT? = nil, currency: String? = nil, fuel: PCPayFuel? = nil, fuelAmount: Decimal? = nil, fuelProductName: String? = nil, issuerPRN: String? = nil, merchantPRN: String? = nil, mileage: Int? = nil, numberPlate: String? = nil, priceExcludingVAT: Decimal? = nil, priceIncludingVAT: Decimal? = nil, productFlow: String? = nil, vin: String? = nil) {
            self.paymentToken = paymentToken
            self.purposePRN = purposePRN
            self.providerPRN = providerPRN
            self.vat = vat
            self.currency = currency
            self.fuel = fuel
            self.fuelAmount = fuelAmount
            self.fuelProductName = fuelProductName
            self.issuerPRN = issuerPRN
            self.merchantPRN = merchantPRN
            self.mileage = mileage
            self.numberPlate = numberPlate
            self.priceExcludingVAT = priceExcludingVAT
            self.priceIncludingVAT = priceIncludingVAT
            self.productFlow = productFlow
            self.vin = vin
        }

        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: StringCodingKey.self)

            paymentToken = try container.decode("paymentToken")
            purposePRN = try container.decode("purposePRN")
            providerPRN = try container.decode("providerPRN")
            vat = try container.decodeIfPresent("VAT")
            currency = try container.decodeIfPresent("currency")
            fuel = try container.decodeIfPresent("fuel")
            fuelAmount = try container.decodeLosslessDecimal("fuelAmount")
            fuelProductName = try container.decodeIfPresent("fuelProductName")
            issuerPRN = try container.decodeIfPresent("issuerPRN")
            merchantPRN = try container.decodeIfPresent("merchantPRN")
            mileage = try container.decodeIfPresent("mileage")
            numberPlate = try container.decodeIfPresent("numberPlate")
            priceExcludingVAT = try container.decodeLosslessDecimal("priceExcludingVAT")
            priceIncludingVAT = try container.decodeLosslessDecimal("priceIncludingVAT")
            productFlow = try container.decodeIfPresent("productFlow")
            vin = try container.decodeIfPresent("vin")
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: StringCodingKey.self)

            try container.encode(paymentToken, forKey: "paymentToken")
            try container.encode(purposePRN, forKey: "purposePRN")
            try container.encode(providerPRN, forKey: "providerPRN")
            try container.encodeIfPresent(vat, forKey: "VAT")
            try container.encodeIfPresent(currency, forKey: "currency")
            try container.encodeIfPresent(fuel, forKey: "fuel")
            try container.encodeIfPresent(fuelAmount, forKey: "fuelAmount")
            try container.encodeIfPresent(fuelProductName, forKey: "fuelProductName")
            try container.encodeIfPresent(issuerPRN, forKey: "issuerPRN")
            try container.encodeIfPresent(merchantPRN, forKey: "merchantPRN")
            try container.encodeIfPresent(mileage, forKey: "mileage")
            try container.encodeIfPresent(numberPlate, forKey: "numberPlate")
            try container.encodeIfPresent(priceExcludingVAT, forKey: "priceExcludingVAT")
            try container.encodeIfPresent(priceIncludingVAT, forKey: "priceIncludingVAT")
            try container.encodeIfPresent(productFlow, forKey: "productFlow")
            try container.encodeIfPresent(vin, forKey: "vin")
        }

        public func isEqual(to object: Any?) -> Bool {
          guard let object = object as? Attributes else { return false }
          guard self.paymentToken == object.paymentToken else { return false }
          guard self.purposePRN == object.purposePRN else { return false }
          guard self.providerPRN == object.providerPRN else { return false }
          guard self.vat == object.vat else { return false }
          guard self.currency == object.currency else { return false }
          guard self.fuel == object.fuel else { return false }
          guard self.fuelAmount == object.fuelAmount else { return false }
          guard self.fuelProductName == object.fuelProductName else { return false }
          guard self.issuerPRN == object.issuerPRN else { return false }
          guard self.merchantPRN == object.merchantPRN else { return false }
          guard self.mileage == object.mileage else { return false }
          guard self.numberPlate == object.numberPlate else { return false }
          guard self.priceExcludingVAT == object.priceExcludingVAT else { return false }
          guard self.priceIncludingVAT == object.priceIncludingVAT else { return false }
          guard self.productFlow == object.productFlow else { return false }
          guard self.vin == object.vin else { return false }
          return true
        }

        public static func == (lhs: Attributes, rhs: Attributes) -> Bool {
            return lhs.isEqual(to: rhs)
        }
    }

    public init(type: PCPayType, attributes: Attributes, id: ID? = nil) {
        self.type = type
        self.attributes = attributes
        self.id = id
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StringCodingKey.self)

        type = try container.decode("type")
        attributes = try container.decode("attributes")
        id = try container.decodeIfPresent("id")
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StringCodingKey.self)

        try container.encode(type, forKey: "type")
        try container.encode(attributes, forKey: "attributes")
        try container.encodeIfPresent(id, forKey: "id")
    }

    public func isEqual(to object: Any?) -> Bool {
      guard let object = object as? PCPayTransactionCreateRequest else { return false }
      guard self.type == object.type else { return false }
      guard self.attributes == object.attributes else { return false }
      guard self.id == object.id else { return false }
      return true
    }

    public static func == (lhs: PCPayTransactionCreateRequest, rhs: PCPayTransactionCreateRequest) -> Bool {
        return lhs.isEqual(to: rhs)
    }
}
