//
// Generated by SwagGen
// https://github.com/pace/SwagGen
//

import Foundation

public class PCPOIFuelType: APIModel {

    /** Type */
    public enum PCPOIType: String, Codable, Equatable, CaseIterable {
        case fuelType = "fuelType"
    }

    public var attributes: Attributes?

    /** FuelType ID */
    public var id: String?

    /** Type */
    public var type: PCPOIType?

    public class Attributes: APIModel {

        /** Normalized name, i.e., converted to a fuel type. */
        public var fuelType: String?

        /** Product name. */
        public var productName: String?

        public init(fuelType: String? = nil, productName: String? = nil) {
            self.fuelType = fuelType
            self.productName = productName
        }

        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: StringCodingKey.self)

            fuelType = try container.decodeIfPresent("fuelType")
            productName = try container.decodeIfPresent("productName")
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: StringCodingKey.self)

            try container.encodeIfPresent(fuelType, forKey: "fuelType")
            try container.encodeIfPresent(productName, forKey: "productName")
        }

        public func isEqual(to object: Any?) -> Bool {
          guard let object = object as? Attributes else { return false }
          guard self.fuelType == object.fuelType else { return false }
          guard self.productName == object.productName else { return false }
          return true
        }

        public static func == (lhs: Attributes, rhs: Attributes) -> Bool {
            return lhs.isEqual(to: rhs)
        }
    }

    public init(attributes: Attributes? = nil, id: String? = nil, type: PCPOIType? = nil) {
        self.attributes = attributes
        self.id = id
        self.type = type
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StringCodingKey.self)

        attributes = try container.decodeIfPresent("attributes")
        id = try container.decodeIfPresent("id")
        type = try container.decodeIfPresent("type")
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StringCodingKey.self)

        try container.encodeIfPresent(attributes, forKey: "attributes")
        try container.encodeIfPresent(id, forKey: "id")
        try container.encodeIfPresent(type, forKey: "type")
    }

    public func isEqual(to object: Any?) -> Bool {
      guard let object = object as? PCPOIFuelType else { return false }
      guard self.attributes == object.attributes else { return false }
      guard self.id == object.id else { return false }
      guard self.type == object.type else { return false }
      return true
    }

    public static func == (lhs: PCPOIFuelType, rhs: PCPOIFuelType) -> Bool {
        return lhs.isEqual(to: rhs)
    }
}
