//
// Generated by SwagGen
// https://github.com/pace/SwagGen
//

import Foundation

public class PCPayRequestPaymentMethodModelRequest: APIModel {

    public enum PCPayType: String, Codable, Equatable, CaseIterable {
        case paymentMethod = "paymentMethod"
    }

    public var type: PCPayType

    public var attributes: Attributes

    /** Payment method UUID */
    public var id: ID?

    public class Attributes: APIModel {

        /** Point of Interest ID */
        public var poiID: String?

        public init(poiID: String? = nil) {
            self.poiID = poiID
        }

        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: StringCodingKey.self)

            poiID = try container.decodeIfPresent("poiID")
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: StringCodingKey.self)

            try container.encodeIfPresent(poiID, forKey: "poiID")
        }

        public func isEqual(to object: Any?) -> Bool {
          guard let object = object as? Attributes else { return false }
          guard self.poiID == object.poiID else { return false }
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
      guard let object = object as? PCPayRequestPaymentMethodModelRequest else { return false }
      guard self.type == object.type else { return false }
      guard self.attributes == object.attributes else { return false }
      guard self.id == object.id else { return false }
      return true
    }

    public static func == (lhs: PCPayRequestPaymentMethodModelRequest, rhs: PCPayRequestPaymentMethodModelRequest) -> Bool {
        return lhs.isEqual(to: rhs)
    }
}
