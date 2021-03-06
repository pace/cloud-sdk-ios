//
// Generated by SwagGen
// https://github.com/pace/SwagGen
//

import Foundation

public class PCPOIFuelPrice: APIModel {

    /** Fuel price */
    public enum PCPOIType: String, Codable, Equatable, CaseIterable {
        case fuelPrice = "fuelPrice"
    }

    public var attributes: Attributes?

    /** Fuel Price ID */
    public var id: ID?

    /** Fuel price */
    public var type: PCPOIType?

    public class Attributes: APIModel {

        /** Currency as specified in ISO-4217. */
        public var currency: String?

        public var fuelType: PCPOIFuel?

        /** per liter */
        public var price: Double?

        public var productName: String?

        /** Time of FuelPrices last update iso8601 with microseconds UTC */
        public var updatedAt: DateTime?

        public init(currency: String? = nil, fuelType: PCPOIFuel? = nil, price: Double? = nil, productName: String? = nil, updatedAt: DateTime? = nil) {
            self.currency = currency
            self.fuelType = fuelType
            self.price = price
            self.productName = productName
            self.updatedAt = updatedAt
        }

        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: StringCodingKey.self)

            currency = try container.decodeIfPresent("currency")
            fuelType = try container.decodeIfPresent("fuelType")
            price = try container.decodeIfPresent("price")
            productName = try container.decodeIfPresent("productName")
            updatedAt = try container.decodeIfPresent("updatedAt")
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: StringCodingKey.self)

            try container.encodeIfPresent(currency, forKey: "currency")
            try container.encodeIfPresent(fuelType, forKey: "fuelType")
            try container.encodeIfPresent(price, forKey: "price")
            try container.encodeIfPresent(productName, forKey: "productName")
            try container.encodeIfPresent(updatedAt, forKey: "updatedAt")
        }

        public func isEqual(to object: Any?) -> Bool {
          guard let object = object as? Attributes else { return false }
          guard self.currency == object.currency else { return false }
          guard self.fuelType == object.fuelType else { return false }
          guard self.price == object.price else { return false }
          guard self.productName == object.productName else { return false }
          guard self.updatedAt == object.updatedAt else { return false }
          return true
        }

        public static func == (lhs: Attributes, rhs: Attributes) -> Bool {
            return lhs.isEqual(to: rhs)
        }
    }

    public init(attributes: Attributes? = nil, id: ID? = nil, type: PCPOIType? = nil) {
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
      guard let object = object as? PCPOIFuelPrice else { return false }
      guard self.attributes == object.attributes else { return false }
      guard self.id == object.id else { return false }
      guard self.type == object.type else { return false }
      return true
    }

    public static func == (lhs: PCPOIFuelPrice, rhs: PCPOIFuelPrice) -> Bool {
        return lhs.isEqual(to: rhs)
    }
}
