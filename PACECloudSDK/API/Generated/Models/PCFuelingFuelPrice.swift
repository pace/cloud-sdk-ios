//
// Generated by SwagGen
// https://github.com/pace/SwagGen
//

import Foundation

public class PCFuelingFuelPrice: APIModel {

    /** Fuel price */
    public enum PCFuelingType: String, Codable, Equatable, CaseIterable {
        case fuelPrice = "fuelPrice"
    }

    /** Fuel type for cars, based on the EU fuel marking */
    public enum PCFuelingFuelType: String, Codable, Equatable, CaseIterable {
        case ron98 = "ron98"
        case ron98e5 = "ron98e5"
        case ron95e10 = "ron95e10"
        case diesel = "diesel"
        case e85 = "e85"
        case ron91 = "ron91"
        case ron95e5 = "ron95e5"
        case ron100 = "ron100"
        case dieselGtl = "dieselGtl"
        case dieselB0 = "dieselB0"
        case dieselB7 = "dieselB7"
        case dieselB15 = "dieselB15"
        case dieselB20 = "dieselB20"
        case dieselBMix = "dieselBMix"
        case dieselPremium = "dieselPremium"
        case dieselHvo = "dieselHvo"
        case dieselRed = "dieselRed"
        case dieselSynthetic = "dieselSynthetic"
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
        case washerFluid = "washerFluid"
        case twoStroke = "twoStroke"
    }

    /** Fuel Price ID */
    public var id: String?

    /** Fuel price */
    public var type: PCFuelingType?

    /** Currency as specified in ISO-4217. */
    public var currency: String?

    /** Fuel type for cars, based on the EU fuel marking */
    public var fuelType: PCFuelingFuelType?

    /** Price in currency/unit */
    public var price: Decimal?

    public var productName: String?

    /** Fuel measurement unit. Eg: `liter`, `us-gallon`, `uk-gallon`, `kilogram` */
    public var unit: String?

    public init(id: String? = nil, type: PCFuelingType? = nil, currency: String? = nil, fuelType: PCFuelingFuelType? = nil, price: Decimal? = nil, productName: String? = nil, unit: String? = nil) {
        self.id = id
        self.type = type
        self.currency = currency
        self.fuelType = fuelType
        self.price = price
        self.productName = productName
        self.unit = unit
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StringCodingKey.self)

        id = try container.decodeIfPresent("id")
        type = try container.decodeIfPresent("type")
        currency = try container.decodeIfPresent("currency")
        fuelType = try container.decodeIfPresent("fuelType")
        price = try container.decodeLosslessDecimal("price")
        productName = try container.decodeIfPresent("productName")
        unit = try container.decodeIfPresent("unit")
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StringCodingKey.self)

        try container.encodeIfPresent(id, forKey: "id")
        try container.encodeIfPresent(type, forKey: "type")
        try container.encodeIfPresent(currency, forKey: "currency")
        try container.encodeIfPresent(fuelType, forKey: "fuelType")
        try container.encodeIfPresent(price, forKey: "price")
        try container.encodeIfPresent(productName, forKey: "productName")
        try container.encodeIfPresent(unit, forKey: "unit")
    }

    public func isEqual(to object: Any?) -> Bool {
      guard let object = object as? PCFuelingFuelPrice else { return false }
      guard self.id == object.id else { return false }
      guard self.type == object.type else { return false }
      guard self.currency == object.currency else { return false }
      guard self.fuelType == object.fuelType else { return false }
      guard self.price == object.price else { return false }
      guard self.productName == object.productName else { return false }
      guard self.unit == object.unit else { return false }
      return true
    }

    public static func == (lhs: PCFuelingFuelPrice, rhs: PCFuelingFuelPrice) -> Bool {
        return lhs.isEqual(to: rhs)
    }
}
