//
// Generated by SwagGen
// https://github.com/pace/SwagGen
//

import Foundation

public class PCUserPlainOTP: APIModel {

    /** one time password */
    public var otp: String?

    public init(otp: String? = nil) {
        self.otp = otp
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StringCodingKey.self)

        otp = try container.decodeIfPresent("otp")
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StringCodingKey.self)

        try container.encodeIfPresent(otp, forKey: "otp")
    }

    public func isEqual(to object: Any?) -> Bool {
      guard let object = object as? PCUserPlainOTP else { return false }
      guard self.otp == object.otp else { return false }
      return true
    }

    public static func == (lhs: PCUserPlainOTP, rhs: PCUserPlainOTP) -> Bool {
        return lhs.isEqual(to: rhs)
    }
}
