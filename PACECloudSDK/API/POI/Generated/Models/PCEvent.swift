//
// Generated by SwagGen
// https://github.com/pace/SwagGen
//

import Foundation

public class PCEvent: APIModel {

    /** Type */
    public enum PCType: String, Codable, Equatable, CaseIterable {
        case events = "events"
    }

    public var attributes: Attributes?

    /** Event ID */
    public var id: ID?

    /** Type */
    public var type: PCType?

    public class Attributes: APIModel {

        public var createdAt: DateTime?

        public var eventAt: DateTime?

        public var fields: [PCFieldData]?

        /** Tracks who did last change */
        public var userId: ID?

        public init(createdAt: DateTime? = nil, eventAt: DateTime? = nil, fields: [PCFieldData]? = nil, userId: ID? = nil) {
            self.createdAt = createdAt
            self.eventAt = eventAt
            self.fields = fields
            self.userId = userId
        }

        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: StringCodingKey.self)

            createdAt = try container.decodeIfPresent("createdAt")
            eventAt = try container.decodeIfPresent("eventAt")
            fields = try container.decodeArrayIfPresent("fields")
            userId = try container.decodeIfPresent("userId")
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: StringCodingKey.self)

            try container.encodeIfPresent(createdAt, forKey: "createdAt")
            try container.encodeIfPresent(eventAt, forKey: "eventAt")
            try container.encodeIfPresent(fields, forKey: "fields")
            try container.encodeIfPresent(userId, forKey: "userId")
        }

        public func isEqual(to object: Any?) -> Bool {
          guard let object = object as? Attributes else { return false }
          guard self.createdAt == object.createdAt else { return false }
          guard self.eventAt == object.eventAt else { return false }
          guard self.fields == object.fields else { return false }
          guard self.userId == object.userId else { return false }
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
      guard let object = object as? PCEvent else { return false }
      guard self.attributes == object.attributes else { return false }
      guard self.id == object.id else { return false }
      guard self.type == object.type else { return false }
      return true
    }

    public static func == (lhs: PCEvent, rhs: PCEvent) -> Bool {
        return lhs.isEqual(to: rhs)
    }
}
