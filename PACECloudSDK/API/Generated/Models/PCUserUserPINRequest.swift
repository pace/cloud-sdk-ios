//
// Generated by SwagGen
// https://github.com/pace/SwagGen
//

import Foundation

public class PCUserUserPINRequest: APIModel {

    public enum PCUserType: String, Codable, Equatable, CaseIterable {
        case pin = "pin"
    }

    public var attributes: Attributes?

    public var id: String?

    public var type: PCUserType?

    public class Attributes: APIModel {

        /** 4-digit code */
        public var pin: String

        /** user otp */
        public var otp: String

        public init(pin: String, otp: String) {
            self.pin = pin
            self.otp = otp
        }

        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: StringCodingKey.self)

            pin = try container.decode("pin")
            otp = try container.decode("otp")
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: StringCodingKey.self)

            try container.encode(pin, forKey: "pin")
            try container.encode(otp, forKey: "otp")
        }

        public func isEqual(to object: Any?) -> Bool {
          guard let object = object as? Attributes else { return false }
          guard self.pin == object.pin else { return false }
          guard self.otp == object.otp else { return false }
          return true
        }

        public static func == (lhs: Attributes, rhs: Attributes) -> Bool {
            return lhs.isEqual(to: rhs)
        }
    }

    public init(attributes: Attributes? = nil, id: String? = nil, type: PCUserType? = nil) {
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
      guard let object = object as? PCUserUserPINRequest else { return false }
      guard self.attributes == object.attributes else { return false }
      guard self.id == object.id else { return false }
      guard self.type == object.type else { return false }
      return true
    }

    public static func == (lhs: PCUserUserPINRequest, rhs: PCUserUserPINRequest) -> Bool {
        return lhs.isEqual(to: rhs)
    }
}
