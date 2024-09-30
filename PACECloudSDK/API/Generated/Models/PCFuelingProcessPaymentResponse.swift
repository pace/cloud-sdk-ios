//
// Generated by SwagGen
// https://github.com/pace/SwagGen
//

import Foundation

public class PCFuelingProcessPaymentResponse: APIModel {

    public enum PCFuelingType: String, Codable, Equatable, CaseIterable {
        case transaction = "transaction"
    }

    /** Transaction ID */
    public var id: ID?

    public var type: PCFuelingType?

    public var vat: VAT?

    /** Currency as specified in ISO-4217. */
    public var currency: String?

    /** Amount that was discounted. Only if any discounts were applied earlier. */
    public var discountAmount: Decimal?

    /** Driver/vehicle identification */
    public var driverVehicleID: String?

    public var gasStationId: ID?

    /** Mileage in meters */
    public var mileage: Int?

    public var paymentToken: String?

    public var priceIncludingVAT: Decimal?

    public var priceWithoutVAT: Decimal?

    public var pumpId: ID?

    /** Additional information that will be rendered on the receipt */
    public var receiptInformation: [String]?

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

    public init(id: ID? = nil, type: PCFuelingType? = nil, vat: VAT? = nil, currency: String? = nil, discountAmount: Decimal? = nil, driverVehicleID: String? = nil, gasStationId: ID? = nil, mileage: Int? = nil, paymentToken: String? = nil, priceIncludingVAT: Decimal? = nil, priceWithoutVAT: Decimal? = nil, pumpId: ID? = nil, receiptInformation: [String]? = nil, vin: String? = nil) {
        self.id = id
        self.type = type
        self.vat = vat
        self.currency = currency
        self.discountAmount = discountAmount
        self.driverVehicleID = driverVehicleID
        self.gasStationId = gasStationId
        self.mileage = mileage
        self.paymentToken = paymentToken
        self.priceIncludingVAT = priceIncludingVAT
        self.priceWithoutVAT = priceWithoutVAT
        self.pumpId = pumpId
        self.receiptInformation = receiptInformation
        self.vin = vin
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StringCodingKey.self)

        id = try container.decodeIfPresent("id")
        type = try container.decodeIfPresent("type")
        vat = try container.decodeIfPresent("VAT")
        currency = try container.decodeIfPresent("currency")
        discountAmount = try container.decodeLosslessDecimal("discountAmount")
        driverVehicleID = try container.decodeIfPresent("driverVehicleID")
        gasStationId = try container.decodeIfPresent("gasStationId")
        mileage = try container.decodeIfPresent("mileage")
        paymentToken = try container.decodeIfPresent("paymentToken")
        priceIncludingVAT = try container.decodeLosslessDecimal("priceIncludingVAT")
        priceWithoutVAT = try container.decodeLosslessDecimal("priceWithoutVAT")
        pumpId = try container.decodeIfPresent("pumpId")
        receiptInformation = try container.decodeArrayIfPresent("receiptInformation")
        vin = try container.decodeIfPresent("vin")
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StringCodingKey.self)

        try container.encodeIfPresent(id, forKey: "id")
        try container.encodeIfPresent(type, forKey: "type")
        try container.encodeIfPresent(vat, forKey: "VAT")
        try container.encodeIfPresent(currency, forKey: "currency")
        try container.encodeIfPresent(discountAmount, forKey: "discountAmount")
        try container.encodeIfPresent(driverVehicleID, forKey: "driverVehicleID")
        try container.encodeIfPresent(gasStationId, forKey: "gasStationId")
        try container.encodeIfPresent(mileage, forKey: "mileage")
        try container.encodeIfPresent(paymentToken, forKey: "paymentToken")
        try container.encodeIfPresent(priceIncludingVAT, forKey: "priceIncludingVAT")
        try container.encodeIfPresent(priceWithoutVAT, forKey: "priceWithoutVAT")
        try container.encodeIfPresent(pumpId, forKey: "pumpId")
        try container.encodeIfPresent(receiptInformation, forKey: "receiptInformation")
        try container.encodeIfPresent(vin, forKey: "vin")
    }

    public func isEqual(to object: Any?) -> Bool {
      guard let object = object as? PCFuelingProcessPaymentResponse else { return false }
      guard self.id == object.id else { return false }
      guard self.type == object.type else { return false }
      guard self.vat == object.vat else { return false }
      guard self.currency == object.currency else { return false }
      guard self.discountAmount == object.discountAmount else { return false }
      guard self.driverVehicleID == object.driverVehicleID else { return false }
      guard self.gasStationId == object.gasStationId else { return false }
      guard self.mileage == object.mileage else { return false }
      guard self.paymentToken == object.paymentToken else { return false }
      guard self.priceIncludingVAT == object.priceIncludingVAT else { return false }
      guard self.priceWithoutVAT == object.priceWithoutVAT else { return false }
      guard self.pumpId == object.pumpId else { return false }
      guard self.receiptInformation == object.receiptInformation else { return false }
      guard self.vin == object.vin else { return false }
      return true
    }

    public static func == (lhs: PCFuelingProcessPaymentResponse, rhs: PCFuelingProcessPaymentResponse) -> Bool {
        return lhs.isEqual(to: rhs)
    }
}
