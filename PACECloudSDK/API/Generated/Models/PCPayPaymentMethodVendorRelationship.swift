//
// Generated by SwagGen
// https://github.com/pace/SwagGen
//

import Foundation

public class PCPayPaymentMethodVendorRelationship: APIModel {

    public var data: DataType?

    public class DataType: APIModel {

        public enum PCPayType: String, Codable, Equatable, CaseIterable {
            case paymentMethodVendor = "paymentMethodVendor"
        }

        public var id: ID?

        public var type: PCPayType?

        public init(id: ID? = nil, type: PCPayType? = nil) {
            self.id = id
            self.type = type
        }

        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: StringCodingKey.self)

            id = try container.decodeIfPresent("id")
            type = try container.decodeIfPresent("type")
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: StringCodingKey.self)

            try container.encodeIfPresent(id, forKey: "id")
            try container.encodeIfPresent(type, forKey: "type")
        }

        public func isEqual(to object: Any?) -> Bool {
          guard let object = object as? DataType else { return false }
          guard self.id == object.id else { return false }
          guard self.type == object.type else { return false }
          return true
        }

        public static func == (lhs: DataType, rhs: DataType) -> Bool {
            return lhs.isEqual(to: rhs)
        }
    }

    public init(data: DataType? = nil) {
        self.data = data
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StringCodingKey.self)

        data = try container.decodeIfPresent("data")
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StringCodingKey.self)

        try container.encodeIfPresent(data, forKey: "data")
    }

    public func isEqual(to object: Any?) -> Bool {
      guard let object = object as? PCPayPaymentMethodVendorRelationship else { return false }
      guard self.data == object.data else { return false }
      return true
    }

    public static func == (lhs: PCPayPaymentMethodVendorRelationship, rhs: PCPayPaymentMethodVendorRelationship) -> Bool {
        return lhs.isEqual(to: rhs)
    }
}
