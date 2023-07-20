//
// Generated by SwagGen
// https://github.com/pace/SwagGen
//

import Foundation

public class PCWalletGetTicketResponse: APIModel {

    /** the unique identifier of the ticket */
    public var id: String

    /** ticket type, for now only `washing` is supported */
    public var type: PCWalletTicketType

    /** ticket code for redeeming the ticket */
    public var code: String

    /** readable name of the ticket */
    public var displayName: String

    /** detailed description of the ticket */
    public var displayDescription: String

    /** expiry date of the ticket ISO 8601 */
    public var expiresAt: DateTime

    public var vat: VAT?

    public var currency: String?

    public var location: PCWalletPayApiReadOnlyLocation?

    public var priceIncludingVAT: Double?

    public var priceWithoutVAT: Double?

    public class VAT: APIModel {

        public var amount: Double?

        public var rate: Double?

        public init(amount: Double? = nil, rate: Double? = nil) {
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

    public init(id: String, type: PCWalletTicketType, code: String, displayName: String, displayDescription: String, expiresAt: DateTime, vat: VAT? = nil, currency: String? = nil, location: PCWalletPayApiReadOnlyLocation? = nil, priceIncludingVAT: Double? = nil, priceWithoutVAT: Double? = nil) {
        self.id = id
        self.type = type
        self.code = code
        self.displayName = displayName
        self.displayDescription = displayDescription
        self.expiresAt = expiresAt
        self.vat = vat
        self.currency = currency
        self.location = location
        self.priceIncludingVAT = priceIncludingVAT
        self.priceWithoutVAT = priceWithoutVAT
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StringCodingKey.self)

        id = try container.decode("id")
        type = try container.decode("type")
        code = try container.decode("code")
        displayName = try container.decode("displayName")
        displayDescription = try container.decode("displayDescription")
        expiresAt = try container.decode("expiresAt")
        vat = try container.decodeIfPresent("VAT")
        currency = try container.decodeIfPresent("currency")
        location = try container.decodeIfPresent("location")
        priceIncludingVAT = try container.decodeIfPresent("priceIncludingVAT")
        priceWithoutVAT = try container.decodeIfPresent("priceWithoutVAT")
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StringCodingKey.self)

        try container.encode(id, forKey: "id")
        try container.encode(type, forKey: "type")
        try container.encode(code, forKey: "code")
        try container.encode(displayName, forKey: "displayName")
        try container.encode(displayDescription, forKey: "displayDescription")
        try container.encode(expiresAt, forKey: "expiresAt")
        try container.encodeIfPresent(vat, forKey: "VAT")
        try container.encodeIfPresent(currency, forKey: "currency")
        try container.encodeIfPresent(location, forKey: "location")
        try container.encodeIfPresent(priceIncludingVAT, forKey: "priceIncludingVAT")
        try container.encodeIfPresent(priceWithoutVAT, forKey: "priceWithoutVAT")
    }

    public func isEqual(to object: Any?) -> Bool {
      guard let object = object as? PCWalletGetTicketResponse else { return false }
      guard self.id == object.id else { return false }
      guard self.type == object.type else { return false }
      guard self.code == object.code else { return false }
      guard self.displayName == object.displayName else { return false }
      guard self.displayDescription == object.displayDescription else { return false }
      guard self.expiresAt == object.expiresAt else { return false }
      guard self.vat == object.vat else { return false }
      guard self.currency == object.currency else { return false }
      guard self.location == object.location else { return false }
      guard self.priceIncludingVAT == object.priceIncludingVAT else { return false }
      guard self.priceWithoutVAT == object.priceWithoutVAT else { return false }
      return true
    }

    public static func == (lhs: PCWalletGetTicketResponse, rhs: PCWalletGetTicketResponse) -> Bool {
        return lhs.isEqual(to: rhs)
    }
}
