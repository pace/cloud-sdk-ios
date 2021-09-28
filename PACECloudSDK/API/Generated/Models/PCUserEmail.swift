//
// Generated by SwagGen
// https://github.com/pace/SwagGen
//

import Foundation

public class PCUserEmail: APIModel {

    /** The email the user wants to use. */
    public var email: String?

    public init(email: String? = nil) {
        self.email = email
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StringCodingKey.self)

        email = try container.decodeIfPresent("email")
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StringCodingKey.self)

        try container.encodeIfPresent(email, forKey: "email")
    }

    public func isEqual(to object: Any?) -> Bool {
      guard let object = object as? PCUserEmail else { return false }
      guard self.email == object.email else { return false }
      return true
    }

    public static func == (lhs: PCUserEmail, rhs: PCUserEmail) -> Bool {
        return lhs.isEqual(to: rhs)
    }
}
