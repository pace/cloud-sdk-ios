//
// Generated by SwagGen
// https://github.com/pace/SwagGen
//

import Foundation

public class PCPayPaymentMethod: APIModel {

    public enum PCPayType: String, Codable, Equatable, CaseIterable {
        case paymentMethod = "paymentMethod"
    }

    /** The desired status for a payment method is `verified`, this means the method is ready to use.
    A payment method that has the status `created` has yet to be verified. This is the case for payment methods,
    which have an asynchronous verification process, e.g., paydirekt (waiting for an email).
     */
    public enum PCPayStatus: String, Codable, Equatable, CaseIterable {
        case created = "created"
        case verified = "verified"
        case pending = "pending"
        case unacceptable = "unacceptable"
    }

    /** Payment method ID */
    public var id: ID?

    public var links: Links?

    public var meta: Meta?

    public var type: PCPayType?

    public var paymentMethodKind: PCPayPaymentMethodKind?

    public var paymentMethodVendor: PCPayPaymentMethodVendor?

    public var paymentTokens: [PCPayPaymentToken]?

    /** Customer chosen alias for the payment method */
    public var alias: String?

    /** URL for the user to call in order to approve this payment method. */
    public var approvalURL: String?

    /** Expiry date of the payment method. If empty or not present the payment method does not have an expiry date. */
    public var expiry: DateTime?

    public var identificationString: String?

    /** Implicit (`true`) payment methods are read-only and cannot be deleted, e.g., ApplePay */
    public var implicit: Bool?

    /** Indicates if the payment method is eligible for discounts. */
    public var isEligibleForDiscounts: Bool?

    /** one of sepa, creditcard, paypal, paydirekt, dkv, applepay, ... */
    public var kind: String?

    /** Managed (`true`) payment methods are read-only and cannot be deleted other than by the client (oauth/oidc) that created them. */
    public var managed: Bool?

    public var mandatoryAuthorisationAttributes: [MandatoryAuthorisationAttributes]?

    /** Identifies if the payment method is a PACE payment method (`true`) or a broker method (`false`) */
    public var pacePay: Bool?

    /** The desired status for a payment method is `verified`, this means the method is ready to use.
A payment method that has the status `created` has yet to be verified. This is the case for payment methods,
which have an asynchronous verification process, e.g., paydirekt (waiting for an email).
 */
    public var status: PCPayStatus?

    /** indicates if the payment method kind requires two factors later on */
    public var twoFactor: Bool?

    /** PACE resource name(s) to payment method vendor */
    public var vendorPRN: String?

    public class Links: APIModel {

        public var authorize: Authorize?

        public class Authorize: APIModel {

            public var href: String?

            public var meta: Meta?

            public class Meta: APIModel {

                public enum PCPayAuthFlow: String, Codable, Equatable, CaseIterable {
                    case tokenProvided = "token-provided"
                    case methodOnboarded = "method-onboarded"
                }

                public var authFlow: PCPayAuthFlow?

                public init(authFlow: PCPayAuthFlow? = nil) {
                    self.authFlow = authFlow
                }

                public required init(from decoder: Decoder) throws {
                    let container = try decoder.container(keyedBy: StringCodingKey.self)

                    authFlow = try container.decodeIfPresent("authFlow")
                }

                public func encode(to encoder: Encoder) throws {
                    var container = encoder.container(keyedBy: StringCodingKey.self)

                    try container.encodeIfPresent(authFlow, forKey: "authFlow")
                }

                public func isEqual(to object: Any?) -> Bool {
                  guard let object = object as? Meta else { return false }
                  guard self.authFlow == object.authFlow else { return false }
                  return true
                }

                public static func == (lhs: Meta, rhs: Meta) -> Bool {
                    return lhs.isEqual(to: rhs)
                }
            }

            public init(href: String? = nil, meta: Meta? = nil) {
                self.href = href
                self.meta = meta
            }

            public required init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: StringCodingKey.self)

                href = try container.decodeIfPresent("href")
                meta = try container.decodeIfPresent("meta")
            }

            public func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: StringCodingKey.self)

                try container.encodeIfPresent(href, forKey: "href")
                try container.encodeIfPresent(meta, forKey: "meta")
            }

            public func isEqual(to object: Any?) -> Bool {
              guard let object = object as? Authorize else { return false }
              guard self.href == object.href else { return false }
              guard self.meta == object.meta else { return false }
              return true
            }

            public static func == (lhs: Authorize, rhs: Authorize) -> Bool {
                return lhs.isEqual(to: rhs)
            }
        }

        public init(authorize: Authorize? = nil) {
            self.authorize = authorize
        }

        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: StringCodingKey.self)

            authorize = try container.decodeIfPresent("authorize")
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: StringCodingKey.self)

            try container.encodeIfPresent(authorize, forKey: "authorize")
        }

        public func isEqual(to object: Any?) -> Bool {
          guard let object = object as? Links else { return false }
          guard self.authorize == object.authorize else { return false }
          return true
        }

        public static func == (lhs: Links, rhs: Links) -> Bool {
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

    /** Mandatory transaction attribute validator */
    public class MandatoryAuthorisationAttributes: APIModel {

        public var maxLength: Int?

        public var name: String?

        public var regex: String?

        public init(maxLength: Int? = nil, name: String? = nil, regex: String? = nil) {
            self.maxLength = maxLength
            self.name = name
            self.regex = regex
        }

        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: StringCodingKey.self)

            maxLength = try container.decodeIfPresent("maxLength")
            name = try container.decodeIfPresent("name")
            regex = try container.decodeIfPresent("regex")
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: StringCodingKey.self)

            try container.encodeIfPresent(maxLength, forKey: "maxLength")
            try container.encodeIfPresent(name, forKey: "name")
            try container.encodeIfPresent(regex, forKey: "regex")
        }

        public func isEqual(to object: Any?) -> Bool {
          guard let object = object as? MandatoryAuthorisationAttributes else { return false }
          guard self.maxLength == object.maxLength else { return false }
          guard self.name == object.name else { return false }
          guard self.regex == object.regex else { return false }
          return true
        }

        public static func == (lhs: MandatoryAuthorisationAttributes, rhs: MandatoryAuthorisationAttributes) -> Bool {
            return lhs.isEqual(to: rhs)
        }
    }

    public init(id: ID? = nil, links: Links? = nil, meta: Meta? = nil, type: PCPayType? = nil, paymentMethodKind: PCPayPaymentMethodKind? = nil, paymentMethodVendor: PCPayPaymentMethodVendor? = nil, paymentTokens: [PCPayPaymentToken]? = nil, alias: String? = nil, approvalURL: String? = nil, expiry: DateTime? = nil, identificationString: String? = nil, implicit: Bool? = nil, isEligibleForDiscounts: Bool? = nil, kind: String? = nil, managed: Bool? = nil, mandatoryAuthorisationAttributes: [MandatoryAuthorisationAttributes]? = nil, pacePay: Bool? = nil, status: PCPayStatus? = nil, twoFactor: Bool? = nil, vendorPRN: String? = nil) {
        self.id = id
        self.links = links
        self.meta = meta
        self.type = type
        self.paymentMethodKind = paymentMethodKind
        self.paymentMethodVendor = paymentMethodVendor
        self.paymentTokens = paymentTokens
        self.alias = alias
        self.approvalURL = approvalURL
        self.expiry = expiry
        self.identificationString = identificationString
        self.implicit = implicit
        self.isEligibleForDiscounts = isEligibleForDiscounts
        self.kind = kind
        self.managed = managed
        self.mandatoryAuthorisationAttributes = mandatoryAuthorisationAttributes
        self.pacePay = pacePay
        self.status = status
        self.twoFactor = twoFactor
        self.vendorPRN = vendorPRN
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StringCodingKey.self)

        id = try container.decodeIfPresent("id")
        links = try container.decodeIfPresent("links")
        meta = try container.decodeIfPresent("meta")
        type = try container.decodeIfPresent("type")
        paymentMethodKind = try container.decodeIfPresent("paymentMethodKind")
        paymentMethodVendor = try container.decodeIfPresent("paymentMethodVendor")
        paymentTokens = try container.decodeIfPresent("paymentTokens")
        alias = try container.decodeIfPresent("alias")
        approvalURL = try container.decodeIfPresent("approvalURL")
        expiry = try container.decodeIfPresent("expiry")
        identificationString = try container.decodeIfPresent("identificationString")
        implicit = try container.decodeIfPresent("implicit")
        isEligibleForDiscounts = try container.decodeIfPresent("isEligibleForDiscounts")
        kind = try container.decodeIfPresent("kind")
        managed = try container.decodeIfPresent("managed")
        mandatoryAuthorisationAttributes = try container.decodeArrayIfPresent("mandatoryAuthorisationAttributes")
        pacePay = try container.decodeIfPresent("pacePay")
        status = try container.decodeIfPresent("status")
        twoFactor = try container.decodeIfPresent("twoFactor")
        vendorPRN = try container.decodeIfPresent("vendorPRN")
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StringCodingKey.self)

        try container.encodeIfPresent(id, forKey: "id")
        try container.encodeIfPresent(links, forKey: "links")
        try container.encodeIfPresent(meta, forKey: "meta")
        try container.encodeIfPresent(type, forKey: "type")
        try container.encodeIfPresent(paymentMethodKind, forKey: "paymentMethodKind")
        try container.encodeIfPresent(paymentMethodVendor, forKey: "paymentMethodVendor")
        try container.encodeIfPresent(paymentTokens, forKey: "paymentTokens")
        try container.encodeIfPresent(alias, forKey: "alias")
        try container.encodeIfPresent(approvalURL, forKey: "approvalURL")
        try container.encodeIfPresent(expiry, forKey: "expiry")
        try container.encodeIfPresent(identificationString, forKey: "identificationString")
        try container.encodeIfPresent(implicit, forKey: "implicit")
        try container.encodeIfPresent(isEligibleForDiscounts, forKey: "isEligibleForDiscounts")
        try container.encodeIfPresent(kind, forKey: "kind")
        try container.encodeIfPresent(managed, forKey: "managed")
        try container.encodeIfPresent(mandatoryAuthorisationAttributes, forKey: "mandatoryAuthorisationAttributes")
        try container.encodeIfPresent(pacePay, forKey: "pacePay")
        try container.encodeIfPresent(status, forKey: "status")
        try container.encodeIfPresent(twoFactor, forKey: "twoFactor")
        try container.encodeIfPresent(vendorPRN, forKey: "vendorPRN")
    }

    public func isEqual(to object: Any?) -> Bool {
      guard let object = object as? PCPayPaymentMethod else { return false }
      guard self.id == object.id else { return false }
      guard self.links == object.links else { return false }
      guard self.meta == object.meta else { return false }
      guard self.type == object.type else { return false }
      guard self.paymentMethodKind == object.paymentMethodKind else { return false }
      guard self.paymentMethodVendor == object.paymentMethodVendor else { return false }
      guard self.paymentTokens == object.paymentTokens else { return false }
      guard self.alias == object.alias else { return false }
      guard self.approvalURL == object.approvalURL else { return false }
      guard self.expiry == object.expiry else { return false }
      guard self.identificationString == object.identificationString else { return false }
      guard self.implicit == object.implicit else { return false }
      guard self.isEligibleForDiscounts == object.isEligibleForDiscounts else { return false }
      guard self.kind == object.kind else { return false }
      guard self.managed == object.managed else { return false }
      guard self.mandatoryAuthorisationAttributes == object.mandatoryAuthorisationAttributes else { return false }
      guard self.pacePay == object.pacePay else { return false }
      guard self.status == object.status else { return false }
      guard self.twoFactor == object.twoFactor else { return false }
      guard self.vendorPRN == object.vendorPRN else { return false }
      return true
    }

    public static func == (lhs: PCPayPaymentMethod, rhs: PCPayPaymentMethod) -> Bool {
        return lhs.isEqual(to: rhs)
    }
}
