//
// Generated by SwagGen
// https://github.com/pace/SwagGen
//

import Foundation

public class PCPolicyRule: APIModel {

    public var field: PCFieldName

    public var priorities: [PCPolicyRulePriority]

    public init(field: PCFieldName, priorities: [PCPolicyRulePriority]) {
        self.field = field
        self.priorities = priorities
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StringCodingKey.self)

        field = try container.decode("field")
        priorities = try container.decodeArray("priorities")
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StringCodingKey.self)

        try container.encode(field, forKey: "field")
        try container.encode(priorities, forKey: "priorities")
    }

    public func isEqual(to object: Any?) -> Bool {
      guard let object = object as? PCPolicyRule else { return false }
      guard self.field == object.field else { return false }
      guard self.priorities == object.priorities else { return false }
      return true
    }

    public static func == (lhs: PCPolicyRule, rhs: PCPolicyRule) -> Bool {
        return lhs.isEqual(to: rhs)
    }
}
