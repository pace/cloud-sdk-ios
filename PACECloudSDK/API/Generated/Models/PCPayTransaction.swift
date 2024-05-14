//
// Generated by SwagGen
// https://github.com/pace/SwagGen
//

import Foundation

public class PCPayTransaction: APIModel {

    public enum PCPayType: String, Codable, Equatable, CaseIterable {
        case transaction = "transaction"
    }

    /** ID of the new transaction. */
    public var id: ID?

    public var links: PCPayTransactionLinks?

    public var type: PCPayType?

    public var discountTokens: [PCPayDiscount]?

    public var vat: VAT?

    /** additional data for omv */
    public var additionalData: String?

    /** ID of the authorization payment token */
    public var authorizePaymentTokenId: ID?

    /** Initial creation date of the transaction (UTC) (https://tools.ietf.org/html/rfc3339#section-5.6).
 */
    public var createdAt: DateTime?

    /** Initial creation date of the transaction (local-time of the gas station/point of interest) (https://tools.ietf.org/html/rfc3339#section-5.6).
 */
    public var createdAtLocaltime: String?

    /** Currency as specified in ISO-4217. */
    public var currency: String?

    /** Amount that was discounted. Only if any discounts were applied earlier. */
    public var discountAmount: Decimal?

    /** Driver/vehicle identification */
    public var driverVehicleID: String?

    /** Description of the error that occured */
    public var error: String?

    public var fuel: PCPayFuel?

    /** PACE resource name */
    public var issuerPRN: String?

    public var location: PCPayReadOnlyLocation?

    /** Current mileage in meters */
    public var mileage: Int?

    /** Number plate of the car */
    public var numberPlate: String?

    /** ID of the paymentMethod */
    public var paymentMethodId: ID?

    /** Payment Method Kind as name. */
    public var paymentMethodKind: String?

    /** Payment token value */
    public var paymentToken: String?

    /** Request ID of the payment token */
    public var paymentTokenRequestID: String?

    /** Request ID of the payment transaction */
    public var paymentTransactionRequestID: String?

    /** If a discount was applied, this is the already fully discounted transaction sum */
    public var priceIncludingVAT: Decimal?

    /** If a discount was applied, this the transaction sum, before applying the discound */
    public var priceIncludingVATBeforeDiscount: Decimal?

    public var priceWithoutVAT: Decimal?

    /** The given productFlow (e.g. preAuth, postPay) */
    public var productFlow: String?

    /** PACE resource name - referring to the transaction purpose with provider details. */
    public var providerPRN: String?

    /** PACE resource name */
    public var purposePRN: String?

    public var references: [String]?

    /** Date of the last update (UTC) (https://tools.ietf.org/html/rfc3339#section-5.6).
 */
    public var updatedAt: DateTime?

    /** Vehicle identification number */
    public var vin: String?

    public class VAT: APIModel {

        public var amount: Decimal?

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

    public init(id: ID? = nil, links: PCPayTransactionLinks? = nil, type: PCPayType? = nil, discountTokens: [PCPayDiscount]? = nil, vat: VAT? = nil, additionalData: String? = nil, authorizePaymentTokenId: ID? = nil, createdAt: DateTime? = nil, createdAtLocaltime: String? = nil, currency: String? = nil, discountAmount: Decimal? = nil, driverVehicleID: String? = nil, error: String? = nil, fuel: PCPayFuel? = nil, issuerPRN: String? = nil, location: PCPayReadOnlyLocation? = nil, mileage: Int? = nil, numberPlate: String? = nil, paymentMethodId: ID? = nil, paymentMethodKind: String? = nil, paymentToken: String? = nil, paymentTokenRequestID: String? = nil, paymentTransactionRequestID: String? = nil, priceIncludingVAT: Decimal? = nil, priceIncludingVATBeforeDiscount: Decimal? = nil, priceWithoutVAT: Decimal? = nil, productFlow: String? = nil, providerPRN: String? = nil, purposePRN: String? = nil, references: [String]? = nil, updatedAt: DateTime? = nil, vin: String? = nil) {
        self.id = id
        self.links = links
        self.type = type
        self.discountTokens = discountTokens
        self.vat = vat
        self.additionalData = additionalData
        self.authorizePaymentTokenId = authorizePaymentTokenId
        self.createdAt = createdAt
        self.createdAtLocaltime = createdAtLocaltime
        self.currency = currency
        self.discountAmount = discountAmount
        self.driverVehicleID = driverVehicleID
        self.error = error
        self.fuel = fuel
        self.issuerPRN = issuerPRN
        self.location = location
        self.mileage = mileage
        self.numberPlate = numberPlate
        self.paymentMethodId = paymentMethodId
        self.paymentMethodKind = paymentMethodKind
        self.paymentToken = paymentToken
        self.paymentTokenRequestID = paymentTokenRequestID
        self.paymentTransactionRequestID = paymentTransactionRequestID
        self.priceIncludingVAT = priceIncludingVAT
        self.priceIncludingVATBeforeDiscount = priceIncludingVATBeforeDiscount
        self.priceWithoutVAT = priceWithoutVAT
        self.productFlow = productFlow
        self.providerPRN = providerPRN
        self.purposePRN = purposePRN
        self.references = references
        self.updatedAt = updatedAt
        self.vin = vin
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StringCodingKey.self)

        id = try container.decodeIfPresent("id")
        links = try container.decodeIfPresent("links")
        type = try container.decodeIfPresent("type")
        discountTokens = try container.decodeIfPresent("discountTokens")
        vat = try container.decodeIfPresent("VAT")
        additionalData = try container.decodeIfPresent("additionalData")
        authorizePaymentTokenId = try container.decodeIfPresent("authorizePaymentTokenId")
        createdAt = try container.decodeIfPresent("createdAt")
        createdAtLocaltime = try container.decodeIfPresent("createdAtLocaltime")
        currency = try container.decodeIfPresent("currency")
        discountAmount = try container.decodeLosslessDecimal("discountAmount")
        driverVehicleID = try container.decodeIfPresent("driverVehicleID")
        error = try container.decodeIfPresent("error")
        fuel = try container.decodeIfPresent("fuel")
        issuerPRN = try container.decodeIfPresent("issuerPRN")
        location = try container.decodeIfPresent("location")
        mileage = try container.decodeIfPresent("mileage")
        numberPlate = try container.decodeIfPresent("numberPlate")
        paymentMethodId = try container.decodeIfPresent("paymentMethodId")
        paymentMethodKind = try container.decodeIfPresent("paymentMethodKind")
        paymentToken = try container.decodeIfPresent("paymentToken")
        paymentTokenRequestID = try container.decodeIfPresent("paymentTokenRequestID")
        paymentTransactionRequestID = try container.decodeIfPresent("paymentTransactionRequestID")
        priceIncludingVAT = try container.decodeLosslessDecimal("priceIncludingVAT")
        priceIncludingVATBeforeDiscount = try container.decodeLosslessDecimal("priceIncludingVATBeforeDiscount")
        priceWithoutVAT = try container.decodeLosslessDecimal("priceWithoutVAT")
        productFlow = try container.decodeIfPresent("productFlow")
        providerPRN = try container.decodeIfPresent("providerPRN")
        purposePRN = try container.decodeIfPresent("purposePRN")
        references = try container.decodeArrayIfPresent("references")
        updatedAt = try container.decodeIfPresent("updatedAt")
        vin = try container.decodeIfPresent("vin")
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StringCodingKey.self)

        try container.encodeIfPresent(id, forKey: "id")
        try container.encodeIfPresent(links, forKey: "links")
        try container.encodeIfPresent(type, forKey: "type")
        try container.encodeIfPresent(discountTokens, forKey: "discountTokens")
        try container.encodeIfPresent(vat, forKey: "VAT")
        try container.encodeIfPresent(additionalData, forKey: "additionalData")
        try container.encodeIfPresent(authorizePaymentTokenId, forKey: "authorizePaymentTokenId")
        try container.encodeIfPresent(createdAt, forKey: "createdAt")
        try container.encodeIfPresent(createdAtLocaltime, forKey: "createdAtLocaltime")
        try container.encodeIfPresent(currency, forKey: "currency")
        try container.encodeIfPresent(discountAmount, forKey: "discountAmount")
        try container.encodeIfPresent(driverVehicleID, forKey: "driverVehicleID")
        try container.encodeIfPresent(error, forKey: "error")
        try container.encodeIfPresent(fuel, forKey: "fuel")
        try container.encodeIfPresent(issuerPRN, forKey: "issuerPRN")
        try container.encodeIfPresent(location, forKey: "location")
        try container.encodeIfPresent(mileage, forKey: "mileage")
        try container.encodeIfPresent(numberPlate, forKey: "numberPlate")
        try container.encodeIfPresent(paymentMethodId, forKey: "paymentMethodId")
        try container.encodeIfPresent(paymentMethodKind, forKey: "paymentMethodKind")
        try container.encodeIfPresent(paymentToken, forKey: "paymentToken")
        try container.encodeIfPresent(paymentTokenRequestID, forKey: "paymentTokenRequestID")
        try container.encodeIfPresent(paymentTransactionRequestID, forKey: "paymentTransactionRequestID")
        try container.encodeIfPresent(priceIncludingVAT, forKey: "priceIncludingVAT")
        try container.encodeIfPresent(priceIncludingVATBeforeDiscount, forKey: "priceIncludingVATBeforeDiscount")
        try container.encodeIfPresent(priceWithoutVAT, forKey: "priceWithoutVAT")
        try container.encodeIfPresent(productFlow, forKey: "productFlow")
        try container.encodeIfPresent(providerPRN, forKey: "providerPRN")
        try container.encodeIfPresent(purposePRN, forKey: "purposePRN")
        try container.encodeIfPresent(references, forKey: "references")
        try container.encodeIfPresent(updatedAt, forKey: "updatedAt")
        try container.encodeIfPresent(vin, forKey: "vin")
    }

    public func isEqual(to object: Any?) -> Bool {
      guard let object = object as? PCPayTransaction else { return false }
      guard self.id == object.id else { return false }
      guard self.links == object.links else { return false }
      guard self.type == object.type else { return false }
      guard self.discountTokens == object.discountTokens else { return false }
      guard self.vat == object.vat else { return false }
      guard self.additionalData == object.additionalData else { return false }
      guard self.authorizePaymentTokenId == object.authorizePaymentTokenId else { return false }
      guard self.createdAt == object.createdAt else { return false }
      guard self.createdAtLocaltime == object.createdAtLocaltime else { return false }
      guard self.currency == object.currency else { return false }
      guard self.discountAmount == object.discountAmount else { return false }
      guard self.driverVehicleID == object.driverVehicleID else { return false }
      guard self.error == object.error else { return false }
      guard self.fuel == object.fuel else { return false }
      guard self.issuerPRN == object.issuerPRN else { return false }
      guard self.location == object.location else { return false }
      guard self.mileage == object.mileage else { return false }
      guard self.numberPlate == object.numberPlate else { return false }
      guard self.paymentMethodId == object.paymentMethodId else { return false }
      guard self.paymentMethodKind == object.paymentMethodKind else { return false }
      guard self.paymentToken == object.paymentToken else { return false }
      guard self.paymentTokenRequestID == object.paymentTokenRequestID else { return false }
      guard self.paymentTransactionRequestID == object.paymentTransactionRequestID else { return false }
      guard self.priceIncludingVAT == object.priceIncludingVAT else { return false }
      guard self.priceIncludingVATBeforeDiscount == object.priceIncludingVATBeforeDiscount else { return false }
      guard self.priceWithoutVAT == object.priceWithoutVAT else { return false }
      guard self.productFlow == object.productFlow else { return false }
      guard self.providerPRN == object.providerPRN else { return false }
      guard self.purposePRN == object.purposePRN else { return false }
      guard self.references == object.references else { return false }
      guard self.updatedAt == object.updatedAt else { return false }
      guard self.vin == object.vin else { return false }
      return true
    }

    public static func == (lhs: PCPayTransaction, rhs: PCPayTransaction) -> Bool {
        return lhs.isEqual(to: rhs)
    }
}
