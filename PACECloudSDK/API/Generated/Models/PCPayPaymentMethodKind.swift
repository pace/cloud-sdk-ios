//
// Generated by SwagGen
// https://github.com/pace/SwagGen
//

import Foundation

public class PCPayPaymentMethodKind: APIModel {

    public enum PCPayType: String, Codable, Equatable, CaseIterable {
        case paymentMethodKind = "paymentMethodKind"
    }

    /** one of sepa, creditcard, paypal, paydirekt, dkv, applepay, ... */
    public var id: String?

    public var type: PCPayType?

    /** Currencies supported by payment method kind */
    public var currencies: [String]?

    /** data privacy information */
    public var dataPrivacy: DataPrivacy?

    /** Indicates whether the payment method is a fuel card. Fuelcard `no` means no. */
    public var fuelcard: Bool?

    /** Indicates whether the payment method has been onboarded implicitely, e.g., an on-device payment method such as Apple Pay or Google Pay.
This field is optional and if not present should be assumed to indicate `implicit=false`.
 */
    public var implicit: Bool?

    /** Indicates whether the payment method can be onboarded/modified. Managed `true` means no. Otherwise yes.
Most payment method kinds are not managed, i.e., `managed=false`.
 */
    public var managed: Bool?

    /** localized name */
    public var name: String?

    /** indicates if the payment method kind requires two factors later on */
    public var twoFactor: Bool?

    /** PACE resource name(s) to payment method vendors */
    public var vendorPRNs: [String]?

    public var vendors: [Vendors]?

    /** data privacy information */
    public class DataPrivacy: APIModel {

        /** Localized data privacy terms. The terms come formatted in multiple ways, which are all equally valid if given. Additional formats might be added in the future. */
        public var terms: Terms?

        /** Localized data privacy terms. The terms come formatted in multiple ways, which are all equally valid if given. Additional formats might be added in the future. */
        public class Terms: APIModel {

            /** Terms formatted as markdown. Does not contain external resources like images. */
            public var html: String?

            /** Terms formatted as markdown. Does not contain external resources like images. */
            public var markdown: String?

            public init(html: String? = nil, markdown: String? = nil) {
                self.html = html
                self.markdown = markdown
            }

            public required init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: StringCodingKey.self)

                html = try container.decodeIfPresent("html")
                markdown = try container.decodeIfPresent("markdown")
            }

            public func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: StringCodingKey.self)

                try container.encodeIfPresent(html, forKey: "html")
                try container.encodeIfPresent(markdown, forKey: "markdown")
            }

            public func isEqual(to object: Any?) -> Bool {
              guard let object = object as? Terms else { return false }
              guard self.html == object.html else { return false }
              guard self.markdown == object.markdown else { return false }
              return true
            }

            public static func == (lhs: Terms, rhs: Terms) -> Bool {
                return lhs.isEqual(to: rhs)
            }
        }

        public init(terms: Terms? = nil) {
            self.terms = terms
        }

        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: StringCodingKey.self)

            terms = try container.decodeIfPresent("terms")
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: StringCodingKey.self)

            try container.encodeIfPresent(terms, forKey: "terms")
        }

        public func isEqual(to object: Any?) -> Bool {
          guard let object = object as? DataPrivacy else { return false }
          guard self.terms == object.terms else { return false }
          return true
        }

        public static func == (lhs: DataPrivacy, rhs: DataPrivacy) -> Bool {
            return lhs.isEqual(to: rhs)
        }
    }

    public class Vendors: APIModel {

        /** ID of the payment method vendor. */
        public var id: ID?

        public var logo: Logo?

        public var name: String?

        public var paymentMethodKindId: String?

        public var slug: String?

        public class Logo: APIModel {

            public var href: String?

            /** variants of the vendor's logo */
            public var variants: [Variants]?

            public class Variants: APIModel {

                public var href: String?

                public init(href: String? = nil) {
                    self.href = href
                }

                public required init(from decoder: Decoder) throws {
                    let container = try decoder.container(keyedBy: StringCodingKey.self)

                    href = try container.decodeIfPresent("href")
                }

                public func encode(to encoder: Encoder) throws {
                    var container = encoder.container(keyedBy: StringCodingKey.self)

                    try container.encodeIfPresent(href, forKey: "href")
                }

                public func isEqual(to object: Any?) -> Bool {
                  guard let object = object as? Variants else { return false }
                  guard self.href == object.href else { return false }
                  return true
                }

                public static func == (lhs: Variants, rhs: Variants) -> Bool {
                    return lhs.isEqual(to: rhs)
                }
            }

            public init(href: String? = nil, variants: [Variants]? = nil) {
                self.href = href
                self.variants = variants
            }

            public required init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: StringCodingKey.self)

                href = try container.decodeIfPresent("href")
                variants = try container.decodeArrayIfPresent("variants")
            }

            public func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: StringCodingKey.self)

                try container.encodeIfPresent(href, forKey: "href")
                try container.encodeIfPresent(variants, forKey: "variants")
            }

            public func isEqual(to object: Any?) -> Bool {
              guard let object = object as? Logo else { return false }
              guard self.href == object.href else { return false }
              guard self.variants == object.variants else { return false }
              return true
            }

            public static func == (lhs: Logo, rhs: Logo) -> Bool {
                return lhs.isEqual(to: rhs)
            }
        }

        public init(id: ID? = nil, logo: Logo? = nil, name: String? = nil, paymentMethodKindId: String? = nil, slug: String? = nil) {
            self.id = id
            self.logo = logo
            self.name = name
            self.paymentMethodKindId = paymentMethodKindId
            self.slug = slug
        }

        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: StringCodingKey.self)

            id = try container.decodeIfPresent("id")
            logo = try container.decodeIfPresent("logo")
            name = try container.decodeIfPresent("name")
            paymentMethodKindId = try container.decodeIfPresent("paymentMethodKindId")
            slug = try container.decodeIfPresent("slug")
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: StringCodingKey.self)

            try container.encodeIfPresent(id, forKey: "id")
            try container.encodeIfPresent(logo, forKey: "logo")
            try container.encodeIfPresent(name, forKey: "name")
            try container.encodeIfPresent(paymentMethodKindId, forKey: "paymentMethodKindId")
            try container.encodeIfPresent(slug, forKey: "slug")
        }

        public func isEqual(to object: Any?) -> Bool {
          guard let object = object as? Vendors else { return false }
          guard self.id == object.id else { return false }
          guard self.logo == object.logo else { return false }
          guard self.name == object.name else { return false }
          guard self.paymentMethodKindId == object.paymentMethodKindId else { return false }
          guard self.slug == object.slug else { return false }
          return true
        }

        public static func == (lhs: Vendors, rhs: Vendors) -> Bool {
            return lhs.isEqual(to: rhs)
        }
    }

    public init(id: String? = nil, type: PCPayType? = nil, currencies: [String]? = nil, dataPrivacy: DataPrivacy? = nil, fuelcard: Bool? = nil, implicit: Bool? = nil, managed: Bool? = nil, name: String? = nil, twoFactor: Bool? = nil, vendorPRNs: [String]? = nil, vendors: [Vendors]? = nil) {
        self.id = id
        self.type = type
        self.currencies = currencies
        self.dataPrivacy = dataPrivacy
        self.fuelcard = fuelcard
        self.implicit = implicit
        self.managed = managed
        self.name = name
        self.twoFactor = twoFactor
        self.vendorPRNs = vendorPRNs
        self.vendors = vendors
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StringCodingKey.self)

        id = try container.decodeIfPresent("id")
        type = try container.decodeIfPresent("type")
        currencies = try container.decodeArrayIfPresent("currencies")
        dataPrivacy = try container.decodeIfPresent("dataPrivacy")
        fuelcard = try container.decodeIfPresent("fuelcard")
        implicit = try container.decodeIfPresent("implicit")
        managed = try container.decodeIfPresent("managed")
        name = try container.decodeIfPresent("name")
        twoFactor = try container.decodeIfPresent("twoFactor")
        vendorPRNs = try container.decodeArrayIfPresent("vendorPRNs")
        vendors = try container.decodeArrayIfPresent("vendors")
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StringCodingKey.self)

        try container.encodeIfPresent(id, forKey: "id")
        try container.encodeIfPresent(type, forKey: "type")
        try container.encodeIfPresent(currencies, forKey: "currencies")
        try container.encodeIfPresent(dataPrivacy, forKey: "dataPrivacy")
        try container.encodeIfPresent(fuelcard, forKey: "fuelcard")
        try container.encodeIfPresent(implicit, forKey: "implicit")
        try container.encodeIfPresent(managed, forKey: "managed")
        try container.encodeIfPresent(name, forKey: "name")
        try container.encodeIfPresent(twoFactor, forKey: "twoFactor")
        try container.encodeIfPresent(vendorPRNs, forKey: "vendorPRNs")
        try container.encodeIfPresent(vendors, forKey: "vendors")
    }

    public func isEqual(to object: Any?) -> Bool {
      guard let object = object as? PCPayPaymentMethodKind else { return false }
      guard self.id == object.id else { return false }
      guard self.type == object.type else { return false }
      guard self.currencies == object.currencies else { return false }
      guard self.dataPrivacy == object.dataPrivacy else { return false }
      guard self.fuelcard == object.fuelcard else { return false }
      guard self.implicit == object.implicit else { return false }
      guard self.managed == object.managed else { return false }
      guard self.name == object.name else { return false }
      guard self.twoFactor == object.twoFactor else { return false }
      guard self.vendorPRNs == object.vendorPRNs else { return false }
      guard self.vendors == object.vendors else { return false }
      return true
    }

    public static func == (lhs: PCPayPaymentMethodKind, rhs: PCPayPaymentMethodKind) -> Bool {
        return lhs.isEqual(to: rhs)
    }
}
