//
// Generated by SwagGen
// https://github.com/pace/SwagGen
//

import Foundation

public class PCPayPaymentToken: APIModel {

    public enum PCPayType: String, Codable, Equatable, CaseIterable {
        case paymentToken = "paymentToken"
    }

    public var attributes: Attributes?

    /** Payment Token ID */
    public var id: String?

    public var relationships: Relationships?

    public var type: PCPayType?

    public class Attributes: APIModel {

        /** The amount that this token represents. */
        public var amount: Double?

        public var currency: PCPayCurrency?

        /** PACE resource name(s) of one or multiple resources, for which the payment was authorized. */
        public var purposePRNs: [String]?

        /** The datetime (iso8601) after which the token is no longer valid. May not be provided. */
        public var validUntil: DateTime?

        /** paymentToken value. Format might change (externally provided - by payment provider) */
        public var value: String?

        public init(amount: Double? = nil, currency: PCPayCurrency? = nil, purposePRNs: [String]? = nil, validUntil: DateTime? = nil, value: String? = nil) {
            self.amount = amount
            self.currency = currency
            self.purposePRNs = purposePRNs
            self.validUntil = validUntil
            self.value = value
        }

        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: StringCodingKey.self)

            amount = try container.decodeIfPresent("amount")
            currency = try container.decodeIfPresent("currency")
            purposePRNs = try container.decodeArrayIfPresent("purposePRNs")
            validUntil = try container.decodeIfPresent("validUntil")
            value = try container.decodeIfPresent("value")
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: StringCodingKey.self)

            try container.encodeIfPresent(amount, forKey: "amount")
            try container.encodeIfPresent(currency, forKey: "currency")
            try container.encodeIfPresent(purposePRNs, forKey: "purposePRNs")
            try container.encodeIfPresent(validUntil, forKey: "validUntil")
            try container.encodeIfPresent(value, forKey: "value")
        }

        public func isEqual(to object: Any?) -> Bool {
          guard let object = object as? Attributes else { return false }
          guard self.amount == object.amount else { return false }
          guard self.currency == object.currency else { return false }
          guard self.purposePRNs == object.purposePRNs else { return false }
          guard self.validUntil == object.validUntil else { return false }
          guard self.value == object.value else { return false }
          return true
        }

        public static func == (lhs: Attributes, rhs: Attributes) -> Bool {
            return lhs.isEqual(to: rhs)
        }
    }

    public class Relationships: APIModel {

        public var paymentMethod: PCPayPaymentMethodRelationship?

        public init(paymentMethod: PCPayPaymentMethodRelationship? = nil) {
            self.paymentMethod = paymentMethod
        }

        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: StringCodingKey.self)

            paymentMethod = try container.decodeIfPresent("paymentMethod")
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: StringCodingKey.self)

            try container.encodeIfPresent(paymentMethod, forKey: "paymentMethod")
        }

        public func isEqual(to object: Any?) -> Bool {
          guard let object = object as? Relationships else { return false }
          guard self.paymentMethod == object.paymentMethod else { return false }
          return true
        }

        public static func == (lhs: Relationships, rhs: Relationships) -> Bool {
            return lhs.isEqual(to: rhs)
        }
    }

    public init(attributes: Attributes? = nil, id: String? = nil, relationships: Relationships? = nil, type: PCPayType? = nil) {
        self.attributes = attributes
        self.id = id
        self.relationships = relationships
        self.type = type
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StringCodingKey.self)

        attributes = try container.decodeIfPresent("attributes")
        id = try container.decodeIfPresent("id")
        relationships = try container.decodeIfPresent("relationships")
        type = try container.decodeIfPresent("type")
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StringCodingKey.self)

        try container.encodeIfPresent(attributes, forKey: "attributes")
        try container.encodeIfPresent(id, forKey: "id")
        try container.encodeIfPresent(relationships, forKey: "relationships")
        try container.encodeIfPresent(type, forKey: "type")
    }

    public func isEqual(to object: Any?) -> Bool {
      guard let object = object as? PCPayPaymentToken else { return false }
      guard self.attributes == object.attributes else { return false }
      guard self.id == object.id else { return false }
      guard self.relationships == object.relationships else { return false }
      guard self.type == object.type else { return false }
      return true
    }

    public static func == (lhs: PCPayPaymentToken, rhs: PCPayPaymentToken) -> Bool {
        return lhs.isEqual(to: rhs)
    }
}
