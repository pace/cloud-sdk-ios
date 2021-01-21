//
// Generated by SwagGen
// https://github.com/pace/SwagGen
//

import Foundation

public class PCFuelingTransactionRequest: APIModel {

    public var data: DataType?

    public class DataType: APIModel {

        public enum PCFuelingType: String, Codable, Equatable, CaseIterable {
            case transaction = "transaction"
        }

        public var type: PCFuelingType

        public var attributes: Attributes

        /** Transaction ID */
        public var id: ID?

        public class Attributes: APIModel {

            /** Fuel type for cars, based on the EU fuel marking */
            public enum PCFuelingCarFuelType: String, Codable, Equatable, CaseIterable {
                case ron98 = "ron98"
                case ron98e5 = "ron98e5"
                case ron95e10 = "ron95e10"
                case diesel = "diesel"
                case e85 = "e85"
                case ron91 = "ron91"
                case ron95e5 = "ron95e5"
                case ron100 = "ron100"
                case dieselGtl = "dieselGtl"
                case dieselB7 = "dieselB7"
                case dieselB15 = "dieselB15"
                case dieselPremium = "dieselPremium"
                case lpg = "lpg"
                case cng = "cng"
                case lng = "lng"
                case h2 = "h2"
                case truckDiesel = "truckDiesel"
                case adBlue = "adBlue"
                case truckAdBlue = "truckAdBlue"
                case truckDieselPremium = "truckDieselPremium"
                case truckLpg = "truckLpg"
                case heatingOil = "heatingOil"
            }

            public enum PCFuelingCurrency: String, Codable, Equatable, CaseIterable {
                case eur = "EUR"
            }

            /** 'Value' field of the payment token (not the payment token ID) */
            public var paymentToken: String

            /** Pump ID */
            public var pumpId: ID

            /** Fuel type for cars, based on the EU fuel marking */
            public var carFuelType: PCFuelingCarFuelType?

            public var currency: PCFuelingCurrency?

            /** Current mileage in meters */
            public var mileage: Int?

            public var priceIncludingVAT: Double?

            /** Vehicle identification number */
            public var vin: String?

            public init(paymentToken: String, pumpId: ID, carFuelType: PCFuelingCarFuelType? = nil, currency: PCFuelingCurrency? = nil, mileage: Int? = nil, priceIncludingVAT: Double? = nil, vin: String? = nil) {
                self.paymentToken = paymentToken
                self.pumpId = pumpId
                self.carFuelType = carFuelType
                self.currency = currency
                self.mileage = mileage
                self.priceIncludingVAT = priceIncludingVAT
                self.vin = vin
            }

            public required init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: StringCodingKey.self)

                paymentToken = try container.decode("paymentToken")
                pumpId = try container.decode("pumpId")
                carFuelType = try container.decodeIfPresent("carFuelType")
                currency = try container.decodeIfPresent("currency")
                mileage = try container.decodeIfPresent("mileage")
                priceIncludingVAT = try container.decodeIfPresent("priceIncludingVAT")
                vin = try container.decodeIfPresent("vin")
            }

            public func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: StringCodingKey.self)

                try container.encode(paymentToken, forKey: "paymentToken")
                try container.encode(pumpId, forKey: "pumpId")
                try container.encodeIfPresent(carFuelType, forKey: "carFuelType")
                try container.encodeIfPresent(currency, forKey: "currency")
                try container.encodeIfPresent(mileage, forKey: "mileage")
                try container.encodeIfPresent(priceIncludingVAT, forKey: "priceIncludingVAT")
                try container.encodeIfPresent(vin, forKey: "vin")
            }

            public func isEqual(to object: Any?) -> Bool {
              guard let object = object as? Attributes else { return false }
              guard self.paymentToken == object.paymentToken else { return false }
              guard self.pumpId == object.pumpId else { return false }
              guard self.carFuelType == object.carFuelType else { return false }
              guard self.currency == object.currency else { return false }
              guard self.mileage == object.mileage else { return false }
              guard self.priceIncludingVAT == object.priceIncludingVAT else { return false }
              guard self.vin == object.vin else { return false }
              return true
            }

            public static func == (lhs: Attributes, rhs: Attributes) -> Bool {
                return lhs.isEqual(to: rhs)
            }
        }

        public init(type: PCFuelingType, attributes: Attributes, id: ID? = nil) {
            self.type = type
            self.attributes = attributes
            self.id = id
        }

        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: StringCodingKey.self)

            type = try container.decode("type")
            attributes = try container.decode("attributes")
            id = try container.decodeIfPresent("id")
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: StringCodingKey.self)

            try container.encode(type, forKey: "type")
            try container.encode(attributes, forKey: "attributes")
            try container.encodeIfPresent(id, forKey: "id")
        }

        public func isEqual(to object: Any?) -> Bool {
          guard let object = object as? DataType else { return false }
          guard self.type == object.type else { return false }
          guard self.attributes == object.attributes else { return false }
          guard self.id == object.id else { return false }
          return true
        }

        public static func == (lhs: DataType, rhs: DataType) -> Bool {
            return lhs.isEqual(to: rhs)
        }
    }

    public init(data: DataType? = nil) {
        self.data = data
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StringCodingKey.self)

        data = try container.decodeIfPresent("data")
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StringCodingKey.self)

        try container.encodeIfPresent(data, forKey: "data")
    }

    public func isEqual(to object: Any?) -> Bool {
      guard let object = object as? PCFuelingTransactionRequest else { return false }
      guard self.data == object.data else { return false }
      return true
    }

    public static func == (lhs: PCFuelingTransactionRequest, rhs: PCFuelingTransactionRequest) -> Bool {
        return lhs.isEqual(to: rhs)
    }
}
