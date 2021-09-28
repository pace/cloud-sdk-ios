//
// Generated by SwagGen
// https://github.com/pace/SwagGen
//

import Foundation

public class PCPayPaymentTokenCreate: APIModel {

    public enum PCPayType: String, Codable, Equatable, CaseIterable {
        case paymentToken = "paymentToken"
    }

    public var type: PCPayType

    public var attributes: Attributes

    /** Unique ID of the new paymentToken. */
    public var id: ID?

    public class Attributes: APIModel {

        /** Currency as specified in ISO-4217. */
        public var currency: String

        public var amount: Double

        /** PACE resource name(s) of one or multiple resources, for which the payment should be authorized. */
        public var purposePRNs: [String]

        /** Set this flag to `true` if you accept the authorized amount to be lower than the requested amount. */
        public var allowPartialAmount: Bool?

        public var discountTokens: [String]?

        /** The code and method for two factor authentication, if required by the payment method */
        public var twoFactor: TwoFactor?

        /** The code and method for two factor authentication, if required by the payment method */
        public class TwoFactor: APIModel {

            /** A single name for the 2fa e.g. `face-id`, `fingerprint`, `biometry`, `password`, `pin` */
            public var method: String?

            /** OTP (One time password) for the authorization. */
            public var otp: String?

            public init(method: String? = nil, otp: String? = nil) {
                self.method = method
                self.otp = otp
            }

            public required init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: StringCodingKey.self)

                method = try container.decodeIfPresent("method")
                otp = try container.decodeIfPresent("otp")
            }

            public func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: StringCodingKey.self)

                try container.encodeIfPresent(method, forKey: "method")
                try container.encodeIfPresent(otp, forKey: "otp")
            }

            public func isEqual(to object: Any?) -> Bool {
              guard let object = object as? TwoFactor else { return false }
              guard self.method == object.method else { return false }
              guard self.otp == object.otp else { return false }
              return true
            }

            public static func == (lhs: TwoFactor, rhs: TwoFactor) -> Bool {
                return lhs.isEqual(to: rhs)
            }
        }

        public init(currency: String, amount: Double, purposePRNs: [String], allowPartialAmount: Bool? = nil, discountTokens: [String]? = nil, twoFactor: TwoFactor? = nil) {
            self.currency = currency
            self.amount = amount
            self.purposePRNs = purposePRNs
            self.allowPartialAmount = allowPartialAmount
            self.discountTokens = discountTokens
            self.twoFactor = twoFactor
        }

        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: StringCodingKey.self)

            currency = try container.decode("currency")
            amount = try container.decode("amount")
            purposePRNs = try container.decodeArray("purposePRNs")
            allowPartialAmount = try container.decodeIfPresent("allowPartialAmount")
            discountTokens = try container.decodeArrayIfPresent("discountTokens")
            twoFactor = try container.decodeIfPresent("twoFactor")
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: StringCodingKey.self)

            try container.encode(currency, forKey: "currency")
            try container.encode(amount, forKey: "amount")
            try container.encode(purposePRNs, forKey: "purposePRNs")
            try container.encodeIfPresent(allowPartialAmount, forKey: "allowPartialAmount")
            try container.encodeIfPresent(discountTokens, forKey: "discountTokens")
            try container.encodeIfPresent(twoFactor, forKey: "twoFactor")
        }

        public func isEqual(to object: Any?) -> Bool {
          guard let object = object as? Attributes else { return false }
          guard self.currency == object.currency else { return false }
          guard self.amount == object.amount else { return false }
          guard self.purposePRNs == object.purposePRNs else { return false }
          guard self.allowPartialAmount == object.allowPartialAmount else { return false }
          guard self.discountTokens == object.discountTokens else { return false }
          guard self.twoFactor == object.twoFactor else { return false }
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
      guard let object = object as? PCPayPaymentTokenCreate else { return false }
      guard self.type == object.type else { return false }
      guard self.attributes == object.attributes else { return false }
      guard self.id == object.id else { return false }
      return true
    }

    public static func == (lhs: PCPayPaymentTokenCreate, rhs: PCPayPaymentTokenCreate) -> Bool {
        return lhs.isEqual(to: rhs)
    }
}
