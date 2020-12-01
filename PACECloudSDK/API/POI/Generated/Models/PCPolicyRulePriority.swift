//
// Generated by SwagGen
// https://github.com/pace/SwagGen
//

import Foundation

public class PCPolicyRulePriority: APIModel {

    /** Tracks who did last change */
    public var sourceId: ID

    /** Time to live in seconds (in relation to other entries) */
    public var timeToLive: Double?

    public init(sourceId: ID, timeToLive: Double? = nil) {
        self.sourceId = sourceId
        self.timeToLive = timeToLive
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StringCodingKey.self)

        sourceId = try container.decode("sourceId")
        timeToLive = try container.decodeIfPresent("timeToLive")
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StringCodingKey.self)

        try container.encode(sourceId, forKey: "sourceId")
        try container.encodeIfPresent(timeToLive, forKey: "timeToLive")
    }

    public func isEqual(to object: Any?) -> Bool {
      guard let object = object as? PCPolicyRulePriority else { return false }
      guard self.sourceId == object.sourceId else { return false }
      guard self.timeToLive == object.timeToLive else { return false }
      return true
    }

    public static func == (lhs: PCPolicyRulePriority, rhs: PCPolicyRulePriority) -> Bool {
        return lhs.isEqual(to: rhs)
    }
}
