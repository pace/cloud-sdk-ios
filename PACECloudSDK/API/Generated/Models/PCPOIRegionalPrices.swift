//
// Generated by SwagGen
// https://github.com/pace/SwagGen
//

import Foundation

public class PCPOIRegionalPrices: APIModel {

    /** Regional prices */
    public var data: [DataType]?

    public class DataType: APIModel {

        /** Type */
        public enum PCPOIType: String, Codable, Equatable, CaseIterable {
            case regionalPrices = "regionalPrices"
        }

        public var attributes: Attributes?

        public var id: PCPOIFuel?

        /** Type */
        public var type: PCPOIType?

        public class Attributes: APIModel {

            /** Average price for this fuel type */
            public var average: Double?

            /** Currency based on country */
            public var currency: String?

            /** Price value indicator below which a price is considered cheap */
            public var lower: Double?

            /** Price value indicator after which a price is considered expensive */
            public var upper: Double?

            public init(average: Double? = nil, currency: String? = nil, lower: Double? = nil, upper: Double? = nil) {
                self.average = average
                self.currency = currency
                self.lower = lower
                self.upper = upper
            }

            public required init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: StringCodingKey.self)

                average = try container.decodeIfPresent("average")
                currency = try container.decodeIfPresent("currency")
                lower = try container.decodeIfPresent("lower")
                upper = try container.decodeIfPresent("upper")
            }

            public func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: StringCodingKey.self)

                try container.encodeIfPresent(average, forKey: "average")
                try container.encodeIfPresent(currency, forKey: "currency")
                try container.encodeIfPresent(lower, forKey: "lower")
                try container.encodeIfPresent(upper, forKey: "upper")
            }

            public func isEqual(to object: Any?) -> Bool {
              guard let object = object as? Attributes else { return false }
              guard self.average == object.average else { return false }
              guard self.currency == object.currency else { return false }
              guard self.lower == object.lower else { return false }
              guard self.upper == object.upper else { return false }
              return true
            }

            public static func == (lhs: Attributes, rhs: Attributes) -> Bool {
                return lhs.isEqual(to: rhs)
            }
        }

        public init(attributes: Attributes? = nil, id: PCPOIFuel? = nil, type: PCPOIType? = nil) {
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
          guard let object = object as? DataType else { return false }
          guard self.attributes == object.attributes else { return false }
          guard self.id == object.id else { return false }
          guard self.type == object.type else { return false }
          return true
        }

        public static func == (lhs: DataType, rhs: DataType) -> Bool {
            return lhs.isEqual(to: rhs)
        }
    }

    public init(data: [DataType]? = nil) {
        self.data = data
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StringCodingKey.self)

        data = try container.decodeArrayIfPresent("data")
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StringCodingKey.self)

        try container.encodeIfPresent(data, forKey: "data")
    }

    public func isEqual(to object: Any?) -> Bool {
      guard let object = object as? PCPOIRegionalPrices else { return false }
      guard self.data == object.data else { return false }
      return true
    }

    public static func == (lhs: PCPOIRegionalPrices, rhs: PCPOIRegionalPrices) -> Bool {
        return lhs.isEqual(to: rhs)
    }
}