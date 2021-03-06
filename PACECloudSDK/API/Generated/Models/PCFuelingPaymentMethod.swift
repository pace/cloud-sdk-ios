//
// Generated by SwagGen
// https://github.com/pace/SwagGen
//

import Foundation

public class PCFuelingPaymentMethod: APIModel {

    public enum PCFuelingType: String, Codable, Equatable, CaseIterable {
        case paymentMethod = "paymentMethod"
    }

    public var attributes: Attributes?

    /** Payment Method ID */
    public var id: String?

    public var meta: Meta?

    public var type: PCFuelingType?

    public class Attributes: APIModel {

        public var identificationString: String?

        /** one of sepa, creditcard, paypal, paydirekt, dkv, applepay, ... */
        public var kind: String?

        /** indicates if the payment method kind requires two factors later on */
        public var twoFactor: Bool?

        /** PACE resource name(s) to payment method vendor */
        public var vendorPRN: String?

        public init(identificationString: String? = nil, kind: String? = nil, twoFactor: Bool? = nil, vendorPRN: String? = nil) {
            self.identificationString = identificationString
            self.kind = kind
            self.twoFactor = twoFactor
            self.vendorPRN = vendorPRN
        }

        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: StringCodingKey.self)

            identificationString = try container.decodeIfPresent("identificationString")
            kind = try container.decodeIfPresent("kind")
            twoFactor = try container.decodeIfPresent("twoFactor")
            vendorPRN = try container.decodeIfPresent("vendorPRN")
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: StringCodingKey.self)

            try container.encodeIfPresent(identificationString, forKey: "identificationString")
            try container.encodeIfPresent(kind, forKey: "kind")
            try container.encodeIfPresent(twoFactor, forKey: "twoFactor")
            try container.encodeIfPresent(vendorPRN, forKey: "vendorPRN")
        }

        public func isEqual(to object: Any?) -> Bool {
          guard let object = object as? Attributes else { return false }
          guard self.identificationString == object.identificationString else { return false }
          guard self.kind == object.kind else { return false }
          guard self.twoFactor == object.twoFactor else { return false }
          guard self.vendorPRN == object.vendorPRN else { return false }
          return true
        }

        public static func == (lhs: Attributes, rhs: Attributes) -> Bool {
            return lhs.isEqual(to: rhs)
        }
    }

    public class Meta: APIModel {

        /** Merchant name if the request was made in a way that a merchant name can be determined. For example if requesting payment methods for a specific gas station, it is the merchant name at that gas station. */
        public var merchantName: String?

        public init(merchantName: String? = nil) {
            self.merchantName = merchantName
        }

        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: StringCodingKey.self)

            merchantName = try container.decodeIfPresent("merchantName")
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: StringCodingKey.self)

            try container.encodeIfPresent(merchantName, forKey: "merchantName")
        }

        public func isEqual(to object: Any?) -> Bool {
          guard let object = object as? Meta else { return false }
          guard self.merchantName == object.merchantName else { return false }
          return true
        }

        public static func == (lhs: Meta, rhs: Meta) -> Bool {
            return lhs.isEqual(to: rhs)
        }
    }

    public init(attributes: Attributes? = nil, id: String? = nil, meta: Meta? = nil, type: PCFuelingType? = nil) {
        self.attributes = attributes
        self.id = id
        self.meta = meta
        self.type = type
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StringCodingKey.self)

        attributes = try container.decodeIfPresent("attributes")
        id = try container.decodeIfPresent("id")
        meta = try container.decodeIfPresent("meta")
        type = try container.decodeIfPresent("type")
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StringCodingKey.self)

        try container.encodeIfPresent(attributes, forKey: "attributes")
        try container.encodeIfPresent(id, forKey: "id")
        try container.encodeIfPresent(meta, forKey: "meta")
        try container.encodeIfPresent(type, forKey: "type")
    }

    public func isEqual(to object: Any?) -> Bool {
      guard let object = object as? PCFuelingPaymentMethod else { return false }
      guard self.attributes == object.attributes else { return false }
      guard self.id == object.id else { return false }
      guard self.meta == object.meta else { return false }
      guard self.type == object.type else { return false }
      return true
    }

    public static func == (lhs: PCFuelingPaymentMethod, rhs: PCFuelingPaymentMethod) -> Bool {
        return lhs.isEqual(to: rhs)
    }
}
