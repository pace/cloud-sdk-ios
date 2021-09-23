//
// Generated by SwagGen
// https://github.com/pace/SwagGen
//

import Foundation

public class PCPayPaymentMethodDKVCreate: APIModel {

    public enum PCPayType: String, Codable, Equatable, CaseIterable {
        case paymentMethod = "paymentMethod"
    }

    public var type: PCPayType

    public var attributes: Attributes?

    /** The ID of this payment method. */
    public var id: ID?

    public class Attributes: APIModel {

        public enum PCPayKind: String, Codable, Equatable, CaseIterable {
            case dkv = "dkv"
        }

        public var kind: PCPayKind

        /** Identifier or PAN (Primary Account Number) representing the DKV Card. The identifier is payment provider specific and provided by the payment provider.
     */
        public var pan: String?

        /** The date the card is expiring */
        public var expiry: DateTime?

        /** Indicates whether this payment method should be managed by the creating client, i.e., no other client can modify or delete this method. */
        public var managed: Bool?

        /** Track 2 data of payment card. */
        public var track2: String?

        public init(kind: PCPayKind, pan: String? = nil, expiry: DateTime? = nil, managed: Bool? = nil, track2: String? = nil) {
            self.kind = kind
            self.pan = pan
            self.expiry = expiry
            self.managed = managed
            self.track2 = track2
        }

        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: StringCodingKey.self)

            kind = try container.decode("kind")
            pan = try container.decodeIfPresent("PAN")
            expiry = try container.decodeIfPresent("expiry")
            managed = try container.decodeIfPresent("managed")
            track2 = try container.decodeIfPresent("track2")
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: StringCodingKey.self)

            try container.encode(kind, forKey: "kind")
            try container.encodeIfPresent(pan, forKey: "PAN")
            try container.encodeIfPresent(expiry, forKey: "expiry")
            try container.encodeIfPresent(managed, forKey: "managed")
            try container.encodeIfPresent(track2, forKey: "track2")
        }

        public func isEqual(to object: Any?) -> Bool {
          guard let object = object as? Attributes else { return false }
          guard self.kind == object.kind else { return false }
          guard self.pan == object.pan else { return false }
          guard self.expiry == object.expiry else { return false }
          guard self.managed == object.managed else { return false }
          guard self.track2 == object.track2 else { return false }
          return true
        }

        public static func == (lhs: Attributes, rhs: Attributes) -> Bool {
            return lhs.isEqual(to: rhs)
        }
    }

    public init(type: PCPayType, attributes: Attributes? = nil, id: ID? = nil) {
        self.type = type
        self.attributes = attributes
        self.id = id
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StringCodingKey.self)

        type = try container.decode("type")
        attributes = try container.decodeIfPresent("attributes")
        id = try container.decodeIfPresent("id")
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StringCodingKey.self)

        try container.encode(type, forKey: "type")
        try container.encodeIfPresent(attributes, forKey: "attributes")
        try container.encodeIfPresent(id, forKey: "id")
    }

    public func isEqual(to object: Any?) -> Bool {
      guard let object = object as? PCPayPaymentMethodDKVCreate else { return false }
      guard self.type == object.type else { return false }
      guard self.attributes == object.attributes else { return false }
      guard self.id == object.id else { return false }
      return true
    }

    public static func == (lhs: PCPayPaymentMethodDKVCreate, rhs: PCPayPaymentMethodDKVCreate) -> Bool {
        return lhs.isEqual(to: rhs)
    }
}
