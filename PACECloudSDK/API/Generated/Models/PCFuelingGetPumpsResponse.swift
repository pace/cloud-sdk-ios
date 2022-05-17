//
// Generated by SwagGen
// https://github.com/pace/SwagGen
//

import Foundation

public class PCFuelingGetPumpsResponse: APIModel {

    public enum PCFuelingType: String, Codable, Equatable, CaseIterable {
        case getPumps = "getPumps"
    }

    /** request ID */
    public var id: ID?

    public var type: PCFuelingType?

    public var pumps: [PCFuelingPump]?

    public init(id: ID? = nil, type: PCFuelingType? = nil, pumps: [PCFuelingPump]? = nil) {
        self.id = id
        self.type = type
        self.pumps = pumps
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StringCodingKey.self)

        id = try container.decodeIfPresent("id")
        type = try container.decodeIfPresent("type")
        pumps = try container.decodeIfPresent("pumps")
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StringCodingKey.self)

        try container.encodeIfPresent(id, forKey: "id")
        try container.encodeIfPresent(type, forKey: "type")
        try container.encodeIfPresent(pumps, forKey: "pumps")
    }

    public func isEqual(to object: Any?) -> Bool {
      guard let object = object as? PCFuelingGetPumpsResponse else { return false }
      guard self.id == object.id else { return false }
      guard self.type == object.type else { return false }
      guard self.pumps == object.pumps else { return false }
      return true
    }

    public static func == (lhs: PCFuelingGetPumpsResponse, rhs: PCFuelingGetPumpsResponse) -> Bool {
        return lhs.isEqual(to: rhs)
    }
}
