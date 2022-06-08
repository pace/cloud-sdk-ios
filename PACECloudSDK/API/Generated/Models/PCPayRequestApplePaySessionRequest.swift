//
// Generated by SwagGen
// https://github.com/pace/SwagGen
//

import Foundation

public class PCPayRequestApplePaySessionRequest: APIModel {

    public enum PCPayType: String, Codable, Equatable, CaseIterable {
        case applePayPaymentSession = "applePayPaymentSession"
    }

    public var type: PCPayType

    public var attributes: Attributes

    /** Unique ID of the new apple pay session. */
    public var id: ID?

    public class Attributes: APIModel {

        /** Schemaless (no http/https!) validation URL obtained by the client through communicating directly with Apple Pay. */
        public var validationURL: String

        public init(validationURL: String) {
            self.validationURL = validationURL
        }

        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: StringCodingKey.self)

            validationURL = try container.decode("validationURL")
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: StringCodingKey.self)

            try container.encode(validationURL, forKey: "validationURL")
        }

        public func isEqual(to object: Any?) -> Bool {
          guard let object = object as? Attributes else { return false }
          guard self.validationURL == object.validationURL else { return false }
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
      guard let object = object as? PCPayRequestApplePaySessionRequest else { return false }
      guard self.type == object.type else { return false }
      guard self.attributes == object.attributes else { return false }
      guard self.id == object.id else { return false }
      return true
    }

    public static func == (lhs: PCPayRequestApplePaySessionRequest, rhs: PCPayRequestApplePaySessionRequest) -> Bool {
        return lhs.isEqual(to: rhs)
    }
}