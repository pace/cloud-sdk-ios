//
// Generated by SwagGen
// https://github.com/pace/SwagGen
//

import Foundation

public class PCSource: APIModel {

    /** Type */
    public enum PCType: String, Codable, Equatable, CaseIterable {
        case sources = "sources"
    }

    public var attributes: Attributes?

    /** Source ID */
    public var id: ID?

    /** Type */
    public var type: PCType?

    public class Attributes: APIModel {

        /** list of ISO-3166-1 ALPHA-2 encoded countries */
        public var countries: [String]?

        public var createdAt: DateTime?

        /** timestamp of last import from source */
        public var lastDataAt: DateTime?

        /** source name, unique */
        public var name: String?

        public var poiType: PCPOIType?

        /** JSON field describing the structure of the updates sent by the data source */
        public var schema: [PCFieldName]?

        public var updatedAt: DateTime?

        public init(countries: [String]? = nil, createdAt: DateTime? = nil, lastDataAt: DateTime? = nil, name: String? = nil, poiType: PCPOIType? = nil, schema: [PCFieldName]? = nil, updatedAt: DateTime? = nil) {
            self.countries = countries
            self.createdAt = createdAt
            self.lastDataAt = lastDataAt
            self.name = name
            self.poiType = poiType
            self.schema = schema
            self.updatedAt = updatedAt
        }

        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: StringCodingKey.self)

            countries = try container.decodeArrayIfPresent("countries")
            createdAt = try container.decodeIfPresent("createdAt")
            lastDataAt = try container.decodeIfPresent("lastDataAt")
            name = try container.decodeIfPresent("name")
            poiType = try container.decodeIfPresent("poiType")
            schema = try container.decodeArrayIfPresent("schema")
            updatedAt = try container.decodeIfPresent("updatedAt")
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: StringCodingKey.self)

            try container.encodeIfPresent(countries, forKey: "countries")
            try container.encodeIfPresent(createdAt, forKey: "createdAt")
            try container.encodeIfPresent(lastDataAt, forKey: "lastDataAt")
            try container.encodeIfPresent(name, forKey: "name")
            try container.encodeIfPresent(poiType, forKey: "poiType")
            try container.encodeIfPresent(schema, forKey: "schema")
            try container.encodeIfPresent(updatedAt, forKey: "updatedAt")
        }

        public func isEqual(to object: Any?) -> Bool {
          guard let object = object as? Attributes else { return false }
          guard self.countries == object.countries else { return false }
          guard self.createdAt == object.createdAt else { return false }
          guard self.lastDataAt == object.lastDataAt else { return false }
          guard self.name == object.name else { return false }
          guard self.poiType == object.poiType else { return false }
          guard self.schema == object.schema else { return false }
          guard self.updatedAt == object.updatedAt else { return false }
          return true
        }

        public static func == (lhs: Attributes, rhs: Attributes) -> Bool {
            return lhs.isEqual(to: rhs)
        }
    }

    public init(attributes: Attributes? = nil, id: ID? = nil, type: PCType? = nil) {
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
      guard let object = object as? PCSource else { return false }
      guard self.attributes == object.attributes else { return false }
      guard self.id == object.id else { return false }
      guard self.type == object.type else { return false }
      return true
    }

    public static func == (lhs: PCSource, rhs: PCSource) -> Bool {
        return lhs.isEqual(to: rhs)
    }
}
