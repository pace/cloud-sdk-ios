//
// Generated by SwagGen
// https://github.com/pace/SwagGen
//

import Foundation

public class PCPayTransactionMetadata: APIModel {

    public var key: String?

    public var value: String?

    public init(key: String? = nil, value: String? = nil) {
        self.key = key
        self.value = value
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StringCodingKey.self)

        key = try container.decodeIfPresent("key")
        value = try container.decodeIfPresent("value")
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StringCodingKey.self)

        try container.encodeIfPresent(key, forKey: "key")
        try container.encodeIfPresent(value, forKey: "value")
    }

    public func isEqual(to object: Any?) -> Bool {
      guard let object = object as? PCPayTransactionMetadata else { return false }
      guard self.key == object.key else { return false }
      guard self.value == object.value else { return false }
      return true
    }

    public static func == (lhs: PCPayTransactionMetadata, rhs: PCPayTransactionMetadata) -> Bool {
        return lhs.isEqual(to: rhs)
    }
}
