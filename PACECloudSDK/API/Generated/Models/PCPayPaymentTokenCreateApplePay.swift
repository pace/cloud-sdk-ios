//
// Generated by SwagGen
// https://github.com/pace/SwagGen
//

import Foundation

public class PCPayPaymentTokenCreateApplePay: APIModel {

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

        public var applePay: ApplePay

        public var discountTokens: [String]?

        /** The code and method for two factor authentication, if required by the payment method */
        public var twoFactor: TwoFactor?

        public class ApplePay: APIModel {

            public var paymentData: PaymentData?

            public var paymentMethod: PaymentMethod?

            public var transactionIdentifier: String?

            public class PaymentData: APIModel {

                public var data: String?

                public var header: Header?

                public var signature: String?

                public var version: String?

                public class Header: APIModel {

                    public var ephemeralPublicKey: String?

                    public var publicKeyHash: String?

                    public var transactionId: String?

                    public init(ephemeralPublicKey: String? = nil, publicKeyHash: String? = nil, transactionId: String? = nil) {
                        self.ephemeralPublicKey = ephemeralPublicKey
                        self.publicKeyHash = publicKeyHash
                        self.transactionId = transactionId
                    }

                    public required init(from decoder: Decoder) throws {
                        let container = try decoder.container(keyedBy: StringCodingKey.self)

                        ephemeralPublicKey = try container.decodeIfPresent("ephemeralPublicKey")
                        publicKeyHash = try container.decodeIfPresent("publicKeyHash")
                        transactionId = try container.decodeIfPresent("transactionId")
                    }

                    public func encode(to encoder: Encoder) throws {
                        var container = encoder.container(keyedBy: StringCodingKey.self)

                        try container.encodeIfPresent(ephemeralPublicKey, forKey: "ephemeralPublicKey")
                        try container.encodeIfPresent(publicKeyHash, forKey: "publicKeyHash")
                        try container.encodeIfPresent(transactionId, forKey: "transactionId")
                    }

                    public func isEqual(to object: Any?) -> Bool {
                      guard let object = object as? Header else { return false }
                      guard self.ephemeralPublicKey == object.ephemeralPublicKey else { return false }
                      guard self.publicKeyHash == object.publicKeyHash else { return false }
                      guard self.transactionId == object.transactionId else { return false }
                      return true
                    }

                    public static func == (lhs: Header, rhs: Header) -> Bool {
                        return lhs.isEqual(to: rhs)
                    }
                }

                public init(data: String? = nil, header: Header? = nil, signature: String? = nil, version: String? = nil) {
                    self.data = data
                    self.header = header
                    self.signature = signature
                    self.version = version
                }

                public required init(from decoder: Decoder) throws {
                    let container = try decoder.container(keyedBy: StringCodingKey.self)

                    data = try container.decodeIfPresent("data")
                    header = try container.decodeIfPresent("header")
                    signature = try container.decodeIfPresent("signature")
                    version = try container.decodeIfPresent("version")
                }

                public func encode(to encoder: Encoder) throws {
                    var container = encoder.container(keyedBy: StringCodingKey.self)

                    try container.encodeIfPresent(data, forKey: "data")
                    try container.encodeIfPresent(header, forKey: "header")
                    try container.encodeIfPresent(signature, forKey: "signature")
                    try container.encodeIfPresent(version, forKey: "version")
                }

                public func isEqual(to object: Any?) -> Bool {
                  guard let object = object as? PaymentData else { return false }
                  guard self.data == object.data else { return false }
                  guard self.header == object.header else { return false }
                  guard self.signature == object.signature else { return false }
                  guard self.version == object.version else { return false }
                  return true
                }

                public static func == (lhs: PaymentData, rhs: PaymentData) -> Bool {
                    return lhs.isEqual(to: rhs)
                }
            }

            public class PaymentMethod: APIModel {

                public var displayName: String?

                public var network: String?

                public var type: String?

                public init(displayName: String? = nil, network: String? = nil, type: String? = nil) {
                    self.displayName = displayName
                    self.network = network
                    self.type = type
                }

                public required init(from decoder: Decoder) throws {
                    let container = try decoder.container(keyedBy: StringCodingKey.self)

                    displayName = try container.decodeIfPresent("displayName")
                    network = try container.decodeIfPresent("network")
                    type = try container.decodeIfPresent("type")
                }

                public func encode(to encoder: Encoder) throws {
                    var container = encoder.container(keyedBy: StringCodingKey.self)

                    try container.encodeIfPresent(displayName, forKey: "displayName")
                    try container.encodeIfPresent(network, forKey: "network")
                    try container.encodeIfPresent(type, forKey: "type")
                }

                public func isEqual(to object: Any?) -> Bool {
                  guard let object = object as? PaymentMethod else { return false }
                  guard self.displayName == object.displayName else { return false }
                  guard self.network == object.network else { return false }
                  guard self.type == object.type else { return false }
                  return true
                }

                public static func == (lhs: PaymentMethod, rhs: PaymentMethod) -> Bool {
                    return lhs.isEqual(to: rhs)
                }
            }

            public init(paymentData: PaymentData? = nil, paymentMethod: PaymentMethod? = nil, transactionIdentifier: String? = nil) {
                self.paymentData = paymentData
                self.paymentMethod = paymentMethod
                self.transactionIdentifier = transactionIdentifier
            }

            public required init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: StringCodingKey.self)

                paymentData = try container.decodeIfPresent("paymentData")
                paymentMethod = try container.decodeIfPresent("paymentMethod")
                transactionIdentifier = try container.decodeIfPresent("transactionIdentifier")
            }

            public func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: StringCodingKey.self)

                try container.encodeIfPresent(paymentData, forKey: "paymentData")
                try container.encodeIfPresent(paymentMethod, forKey: "paymentMethod")
                try container.encodeIfPresent(transactionIdentifier, forKey: "transactionIdentifier")
            }

            public func isEqual(to object: Any?) -> Bool {
              guard let object = object as? ApplePay else { return false }
              guard self.paymentData == object.paymentData else { return false }
              guard self.paymentMethod == object.paymentMethod else { return false }
              guard self.transactionIdentifier == object.transactionIdentifier else { return false }
              return true
            }

            public static func == (lhs: ApplePay, rhs: ApplePay) -> Bool {
                return lhs.isEqual(to: rhs)
            }
        }

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

        public init(currency: String, amount: Double, purposePRNs: [String], applePay: ApplePay, discountTokens: [String]? = nil, twoFactor: TwoFactor? = nil) {
            self.currency = currency
            self.amount = amount
            self.purposePRNs = purposePRNs
            self.applePay = applePay
            self.discountTokens = discountTokens
            self.twoFactor = twoFactor
        }

        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: StringCodingKey.self)

            currency = try container.decode("currency")
            amount = try container.decode("amount")
            purposePRNs = try container.decodeArray("purposePRNs")
            applePay = try container.decode("applePay")
            discountTokens = try container.decodeArrayIfPresent("discountTokens")
            twoFactor = try container.decodeIfPresent("twoFactor")
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: StringCodingKey.self)

            try container.encode(currency, forKey: "currency")
            try container.encode(amount, forKey: "amount")
            try container.encode(purposePRNs, forKey: "purposePRNs")
            try container.encode(applePay, forKey: "applePay")
            try container.encodeIfPresent(discountTokens, forKey: "discountTokens")
            try container.encodeIfPresent(twoFactor, forKey: "twoFactor")
        }

        public func isEqual(to object: Any?) -> Bool {
          guard let object = object as? Attributes else { return false }
          guard self.currency == object.currency else { return false }
          guard self.amount == object.amount else { return false }
          guard self.purposePRNs == object.purposePRNs else { return false }
          guard self.applePay == object.applePay else { return false }
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
      guard let object = object as? PCPayPaymentTokenCreateApplePay else { return false }
      guard self.type == object.type else { return false }
      guard self.attributes == object.attributes else { return false }
      guard self.id == object.id else { return false }
      return true
    }

    public static func == (lhs: PCPayPaymentTokenCreateApplePay, rhs: PCPayPaymentTokenCreateApplePay) -> Bool {
        return lhs.isEqual(to: rhs)
    }
}
