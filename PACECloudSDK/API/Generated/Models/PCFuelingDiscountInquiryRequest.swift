//
// Generated by SwagGen
// https://github.com/pace/SwagGen
//

import Foundation

public class PCFuelingDiscountInquiryRequest: APIModel {

    /** Type */
    public enum PCFuelingType: String, Codable, Equatable, CaseIterable {
        case discountInquiry = "discountInquiry"
    }

    /** Type */
    public var type: PCFuelingType

    /** Discount Inquiry id identifies the clients request uniquely */
    public var id: ID

    public var attributes: Attributes

    public class Attributes: APIModel {

        /** UUID of the payment method that is intended to be used for the payment */
        public var paymentMethodId: ID?

        /** Payment Method Kind as name. */
        public var paymentMethodKind: String?

        public init(paymentMethodId: ID? = nil, paymentMethodKind: String? = nil) {
            self.paymentMethodId = paymentMethodId
            self.paymentMethodKind = paymentMethodKind
        }

        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: StringCodingKey.self)

            paymentMethodId = try container.decodeIfPresent("paymentMethodId")
            paymentMethodKind = try container.decodeIfPresent("paymentMethodKind")
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: StringCodingKey.self)

            try container.encodeIfPresent(paymentMethodId, forKey: "paymentMethodId")
            try container.encodeIfPresent(paymentMethodKind, forKey: "paymentMethodKind")
        }

        public func isEqual(to object: Any?) -> Bool {
          guard let object = object as? Attributes else { return false }
          guard self.paymentMethodId == object.paymentMethodId else { return false }
          guard self.paymentMethodKind == object.paymentMethodKind else { return false }
          return true
        }

        public static func == (lhs: Attributes, rhs: Attributes) -> Bool {
            return lhs.isEqual(to: rhs)
        }
    }

    public init(type: PCFuelingType, id: ID, attributes: Attributes) {
        self.type = type
        self.id = id
        self.attributes = attributes
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StringCodingKey.self)

        type = try container.decode("type")
        id = try container.decode("id")
        attributes = try container.decode("attributes")
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StringCodingKey.self)

        try container.encode(type, forKey: "type")
        try container.encode(id, forKey: "id")
        try container.encode(attributes, forKey: "attributes")
    }

    public func isEqual(to object: Any?) -> Bool {
      guard let object = object as? PCFuelingDiscountInquiryRequest else { return false }
      guard self.type == object.type else { return false }
      guard self.id == object.id else { return false }
      guard self.attributes == object.attributes else { return false }
      return true
    }

    public static func == (lhs: PCFuelingDiscountInquiryRequest, rhs: PCFuelingDiscountInquiryRequest) -> Bool {
        return lhs.isEqual(to: rhs)
    }
}
