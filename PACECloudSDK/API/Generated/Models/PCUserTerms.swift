//
// Generated by SwagGen
// https://github.com/pace/SwagGen
//

import Foundation

public class PCUserTerms: APIModel {

    public enum PCUserType: String, Codable, Equatable, CaseIterable {
        case terms = "Terms"
    }

    public var attributes: Attributes?

    /** Terms ID */
    public var id: ID?

    public var type: PCUserType?

    public class Attributes: APIModel {

        /** Location to the terms of service that need to be accepted */
        public var acceptUrl: String?

        /** Terms of service formatted as markdown */
        public var markdown: String?

        public var version: Double?

        public init(acceptUrl: String? = nil, markdown: String? = nil, version: Double? = nil) {
            self.acceptUrl = acceptUrl
            self.markdown = markdown
            self.version = version
        }

        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: StringCodingKey.self)

            acceptUrl = try container.decodeIfPresent("acceptUrl")
            markdown = try container.decodeIfPresent("markdown")
            version = try container.decodeIfPresent("version")
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: StringCodingKey.self)

            try container.encodeIfPresent(acceptUrl, forKey: "acceptUrl")
            try container.encodeIfPresent(markdown, forKey: "markdown")
            try container.encodeIfPresent(version, forKey: "version")
        }

        public func isEqual(to object: Any?) -> Bool {
          guard let object = object as? Attributes else { return false }
          guard self.acceptUrl == object.acceptUrl else { return false }
          guard self.markdown == object.markdown else { return false }
          guard self.version == object.version else { return false }
          return true
        }

        public static func == (lhs: Attributes, rhs: Attributes) -> Bool {
            return lhs.isEqual(to: rhs)
        }
    }

    public init(attributes: Attributes? = nil, id: ID? = nil, type: PCUserType? = nil) {
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
      guard let object = object as? PCUserTerms else { return false }
      guard self.attributes == object.attributes else { return false }
      guard self.id == object.id else { return false }
      guard self.type == object.type else { return false }
      return true
    }

    public static func == (lhs: PCUserTerms, rhs: PCUserTerms) -> Bool {
        return lhs.isEqual(to: rhs)
    }
}
