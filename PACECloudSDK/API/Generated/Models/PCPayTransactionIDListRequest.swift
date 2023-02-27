//
// Generated by SwagGen
// https://github.com/pace/SwagGen
//

import Foundation

public class PCPayTransactionIDListRequest: APIModel {

    public enum PCPayType: String, Codable, Equatable, CaseIterable {
        case transaction = "transaction"
    }

    public var type: PCPayType

    public var attributes: Attributes

    public var id: ID?

    public class Attributes: APIModel {

        /** The maximum amount of receipts that can be send is 8. */
        public var list: [String]

        public init(list: [String]) {
            self.list = list
        }

        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: StringCodingKey.self)

            list = try container.decodeArray("list")
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: StringCodingKey.self)

            try container.encode(list, forKey: "list")
        }

        public func isEqual(to object: Any?) -> Bool {
          guard let object = object as? Attributes else { return false }
          guard self.list == object.list else { return false }
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
      guard let object = object as? PCPayTransactionIDListRequest else { return false }
      guard self.type == object.type else { return false }
      guard self.attributes == object.attributes else { return false }
      guard self.id == object.id else { return false }
      return true
    }

    public static func == (lhs: PCPayTransactionIDListRequest, rhs: PCPayTransactionIDListRequest) -> Bool {
        return lhs.isEqual(to: rhs)
    }
}
