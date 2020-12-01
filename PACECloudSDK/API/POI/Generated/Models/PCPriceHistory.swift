//
// Generated by SwagGen
// https://github.com/pace/SwagGen
//

import Foundation

public class PCPriceHistory: APIModel {

    public enum PCType: String, Codable, Equatable, CaseIterable {
        case priceHistory = "priceHistory"
    }

    public var attributes: Attributes?

    /** Fuel Type */
    public var id: String?

    public var type: PCType?

    public class Attributes: APIModel {

        public var currency: PCCurrency?

        /** Beginning of time interval */
        public var from: DateTime?

        public var fuelPrices: [FuelPrices]?

        public var productName: String?

        /** End of time interval */
        public var to: DateTime?

        public class FuelPrices: APIModel {

            /** The datetime of the price value */
            public var at: DateTime?

            /** The price at this point in time */
            public var price: Double?

            public init(at: DateTime? = nil, price: Double? = nil) {
                self.at = at
                self.price = price
            }

            public required init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: StringCodingKey.self)

                at = try container.decodeIfPresent("at")
                price = try container.decodeIfPresent("price")
            }

            public func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: StringCodingKey.self)

                try container.encodeIfPresent(at, forKey: "at")
                try container.encodeIfPresent(price, forKey: "price")
            }

            public func isEqual(to object: Any?) -> Bool {
              guard let object = object as? FuelPrices else { return false }
              guard self.at == object.at else { return false }
              guard self.price == object.price else { return false }
              return true
            }

            public static func == (lhs: FuelPrices, rhs: FuelPrices) -> Bool {
                return lhs.isEqual(to: rhs)
            }
        }

        public init(currency: PCCurrency? = nil, from: DateTime? = nil, fuelPrices: [FuelPrices]? = nil, productName: String? = nil, to: DateTime? = nil) {
            self.currency = currency
            self.from = from
            self.fuelPrices = fuelPrices
            self.productName = productName
            self.to = to
        }

        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: StringCodingKey.self)

            currency = try container.decodeIfPresent("currency")
            from = try container.decodeIfPresent("from")
            fuelPrices = try container.decodeArrayIfPresent("fuelPrices")
            productName = try container.decodeIfPresent("productName")
            to = try container.decodeIfPresent("to")
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: StringCodingKey.self)

            try container.encodeIfPresent(currency, forKey: "currency")
            try container.encodeIfPresent(from, forKey: "from")
            try container.encodeIfPresent(fuelPrices, forKey: "fuelPrices")
            try container.encodeIfPresent(productName, forKey: "productName")
            try container.encodeIfPresent(to, forKey: "to")
        }

        public func isEqual(to object: Any?) -> Bool {
          guard let object = object as? Attributes else { return false }
          guard self.currency == object.currency else { return false }
          guard self.from == object.from else { return false }
          guard self.fuelPrices == object.fuelPrices else { return false }
          guard self.productName == object.productName else { return false }
          guard self.to == object.to else { return false }
          return true
        }

        public static func == (lhs: Attributes, rhs: Attributes) -> Bool {
            return lhs.isEqual(to: rhs)
        }
    }

    public init(attributes: Attributes? = nil, id: String? = nil, type: PCType? = nil) {
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
      guard let object = object as? PCPriceHistory else { return false }
      guard self.attributes == object.attributes else { return false }
      guard self.id == object.id else { return false }
      guard self.type == object.type else { return false }
      return true
    }

    public static func == (lhs: PCPriceHistory, rhs: PCPriceHistory) -> Bool {
        return lhs.isEqual(to: rhs)
    }
}
