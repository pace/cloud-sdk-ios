//
// Generated by SwagGen
// https://github.com/pace/SwagGen
//

import Foundation

public class PCPOIGasStation: APIModel {

    public enum PCPOIType: String, Codable, Equatable, CaseIterable {
        case gasStation = "gasStation"
    }

    /** Gas Station ID */
    public var id: ID?

    public var type: PCPOIType?

    public var fuelPrices: [PCPOIFuelPrice]?

    public var locationBasedApps: [PCPOILocationBasedApp]?

    public var referenceStatuses: [PCPOIReferenceStatus]?

    public var sucessorOf: [PCPOIGasStation]?

    public var address: Address?

    public var amenities: [String]?

    public var brand: String?

    public var brandID: String?

    public var contact: Contact?

    public var food: [String]?

    public var latitude: Float?

    public var longitude: Float?

    public var loyaltyPrograms: [String]?

    public var onlinePayment: OnlinePayment?

    public var openingHours: PCPOICommonOpeningHours?

    public var paymentMethods: [String]?

    public var postalServices: [String]?

    public var priceFormat: String?

    /** References are PRNs to external and internal resources that are represented by this poi */
    public var references: [String]?

    public var services: [String]?

    public var shopGoods: [String]?

    public var stationName: String?

    public class Address: APIModel {

        public var city: String?

        /** Country code in as specified in ISO 3166-1. */
        public var countryCode: String?

        public var houseNo: String?

        public var postalCode: String?

        public var street: String?

        public init(city: String? = nil, countryCode: String? = nil, houseNo: String? = nil, postalCode: String? = nil, street: String? = nil) {
            self.city = city
            self.countryCode = countryCode
            self.houseNo = houseNo
            self.postalCode = postalCode
            self.street = street
        }

        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: StringCodingKey.self)

            city = try container.decodeIfPresent("city")
            countryCode = try container.decodeIfPresent("countryCode")
            houseNo = try container.decodeIfPresent("houseNo")
            postalCode = try container.decodeIfPresent("postalCode")
            street = try container.decodeIfPresent("street")
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: StringCodingKey.self)

            try container.encodeIfPresent(city, forKey: "city")
            try container.encodeIfPresent(countryCode, forKey: "countryCode")
            try container.encodeIfPresent(houseNo, forKey: "houseNo")
            try container.encodeIfPresent(postalCode, forKey: "postalCode")
            try container.encodeIfPresent(street, forKey: "street")
        }

        public func isEqual(to object: Any?) -> Bool {
          guard let object = object as? Address else { return false }
          guard self.city == object.city else { return false }
          guard self.countryCode == object.countryCode else { return false }
          guard self.houseNo == object.houseNo else { return false }
          guard self.postalCode == object.postalCode else { return false }
          guard self.street == object.street else { return false }
          return true
        }

        public static func == (lhs: Address, rhs: Address) -> Bool {
            return lhs.isEqual(to: rhs)
        }
    }

    public class Contact: APIModel {

        public enum PCPOIGender: String, Codable, Equatable, CaseIterable {
            case m = "m"
            case f = "f"
            case o = "o"
        }

        public var email: String?

        public var faxNumber: String?

        public var firstName: String?

        public var gender: PCPOIGender?

        public var lastName: String?

        public var phoneNumber: String?

        public init(email: String? = nil, faxNumber: String? = nil, firstName: String? = nil, gender: PCPOIGender? = nil, lastName: String? = nil, phoneNumber: String? = nil) {
            self.email = email
            self.faxNumber = faxNumber
            self.firstName = firstName
            self.gender = gender
            self.lastName = lastName
            self.phoneNumber = phoneNumber
        }

        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: StringCodingKey.self)

            email = try container.decodeIfPresent("email")
            faxNumber = try container.decodeIfPresent("faxNumber")
            firstName = try container.decodeIfPresent("firstName")
            gender = try container.decodeIfPresent("gender")
            lastName = try container.decodeIfPresent("lastName")
            phoneNumber = try container.decodeIfPresent("phoneNumber")
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: StringCodingKey.self)

            try container.encodeIfPresent(email, forKey: "email")
            try container.encodeIfPresent(faxNumber, forKey: "faxNumber")
            try container.encodeIfPresent(firstName, forKey: "firstName")
            try container.encodeIfPresent(gender, forKey: "gender")
            try container.encodeIfPresent(lastName, forKey: "lastName")
            try container.encodeIfPresent(phoneNumber, forKey: "phoneNumber")
        }

        public func isEqual(to object: Any?) -> Bool {
          guard let object = object as? Contact else { return false }
          guard self.email == object.email else { return false }
          guard self.faxNumber == object.faxNumber else { return false }
          guard self.firstName == object.firstName else { return false }
          guard self.gender == object.gender else { return false }
          guard self.lastName == object.lastName else { return false }
          guard self.phoneNumber == object.phoneNumber else { return false }
          return true
        }

        public static func == (lhs: Contact, rhs: Contact) -> Bool {
            return lhs.isEqual(to: rhs)
        }
    }

    public class OnlinePayment: APIModel {

        public var online: Bool?

        public var paymentMethods: [String]?

        public init(online: Bool? = nil, paymentMethods: [String]? = nil) {
            self.online = online
            self.paymentMethods = paymentMethods
        }

        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: StringCodingKey.self)

            online = try container.decodeIfPresent("online")
            paymentMethods = try container.decodeArrayIfPresent("paymentMethods")
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: StringCodingKey.self)

            try container.encodeIfPresent(online, forKey: "online")
            try container.encodeIfPresent(paymentMethods, forKey: "paymentMethods")
        }

        public func isEqual(to object: Any?) -> Bool {
          guard let object = object as? OnlinePayment else { return false }
          guard self.online == object.online else { return false }
          guard self.paymentMethods == object.paymentMethods else { return false }
          return true
        }

        public static func == (lhs: OnlinePayment, rhs: OnlinePayment) -> Bool {
            return lhs.isEqual(to: rhs)
        }
    }

    public init(id: ID? = nil, type: PCPOIType? = nil, fuelPrices: [PCPOIFuelPrice]? = nil, locationBasedApps: [PCPOILocationBasedApp]? = nil, referenceStatuses: [PCPOIReferenceStatus]? = nil, sucessorOf: [PCPOIGasStation]? = nil, address: Address? = nil, amenities: [String]? = nil, brand: String? = nil, brandID: String? = nil, contact: Contact? = nil, food: [String]? = nil, latitude: Float? = nil, longitude: Float? = nil, loyaltyPrograms: [String]? = nil, onlinePayment: OnlinePayment? = nil, openingHours: PCPOICommonOpeningHours? = nil, paymentMethods: [String]? = nil, postalServices: [String]? = nil, priceFormat: String? = nil, references: [String]? = nil, services: [String]? = nil, shopGoods: [String]? = nil, stationName: String? = nil) {
        self.id = id
        self.type = type
        self.fuelPrices = fuelPrices
        self.locationBasedApps = locationBasedApps
        self.referenceStatuses = referenceStatuses
        self.sucessorOf = sucessorOf
        self.address = address
        self.amenities = amenities
        self.brand = brand
        self.brandID = brandID
        self.contact = contact
        self.food = food
        self.latitude = latitude
        self.longitude = longitude
        self.loyaltyPrograms = loyaltyPrograms
        self.onlinePayment = onlinePayment
        self.openingHours = openingHours
        self.paymentMethods = paymentMethods
        self.postalServices = postalServices
        self.priceFormat = priceFormat
        self.references = references
        self.services = services
        self.shopGoods = shopGoods
        self.stationName = stationName
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StringCodingKey.self)

        id = try container.decodeIfPresent("id")
        type = try container.decodeIfPresent("type")
        fuelPrices = try container.decodeIfPresent("fuelPrices")
        locationBasedApps = try container.decodeIfPresent("locationBasedApps")
        referenceStatuses = try container.decodeIfPresent("referenceStatuses")
        sucessorOf = try container.decodeIfPresent("sucessorOf")
        address = try container.decodeIfPresent("address")
        amenities = try container.decodeArrayIfPresent("amenities")
        brand = try container.decodeIfPresent("brand")
        brandID = try container.decodeIfPresent("brandID")
        contact = try container.decodeIfPresent("contact")
        food = try container.decodeArrayIfPresent("food")
        latitude = try container.decodeIfPresent("latitude")
        longitude = try container.decodeIfPresent("longitude")
        loyaltyPrograms = try container.decodeArrayIfPresent("loyaltyPrograms")
        onlinePayment = try container.decodeIfPresent("onlinePayment")
        openingHours = try container.decodeIfPresent("openingHours")
        paymentMethods = try container.decodeArrayIfPresent("paymentMethods")
        postalServices = try container.decodeArrayIfPresent("postalServices")
        priceFormat = try container.decodeIfPresent("priceFormat")
        references = try container.decodeArrayIfPresent("references")
        services = try container.decodeArrayIfPresent("services")
        shopGoods = try container.decodeArrayIfPresent("shopGoods")
        stationName = try container.decodeIfPresent("stationName")
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StringCodingKey.self)

        try container.encodeIfPresent(id, forKey: "id")
        try container.encodeIfPresent(type, forKey: "type")
        try container.encodeIfPresent(fuelPrices, forKey: "fuelPrices")
        try container.encodeIfPresent(locationBasedApps, forKey: "locationBasedApps")
        try container.encodeIfPresent(referenceStatuses, forKey: "referenceStatuses")
        try container.encodeIfPresent(sucessorOf, forKey: "sucessorOf")
        try container.encodeIfPresent(address, forKey: "address")
        try container.encodeIfPresent(amenities, forKey: "amenities")
        try container.encodeIfPresent(brand, forKey: "brand")
        try container.encodeIfPresent(brandID, forKey: "brandID")
        try container.encodeIfPresent(contact, forKey: "contact")
        try container.encodeIfPresent(food, forKey: "food")
        try container.encodeIfPresent(latitude, forKey: "latitude")
        try container.encodeIfPresent(longitude, forKey: "longitude")
        try container.encodeIfPresent(loyaltyPrograms, forKey: "loyaltyPrograms")
        try container.encodeIfPresent(onlinePayment, forKey: "onlinePayment")
        try container.encodeIfPresent(openingHours, forKey: "openingHours")
        try container.encodeIfPresent(paymentMethods, forKey: "paymentMethods")
        try container.encodeIfPresent(postalServices, forKey: "postalServices")
        try container.encodeIfPresent(priceFormat, forKey: "priceFormat")
        try container.encodeIfPresent(references, forKey: "references")
        try container.encodeIfPresent(services, forKey: "services")
        try container.encodeIfPresent(shopGoods, forKey: "shopGoods")
        try container.encodeIfPresent(stationName, forKey: "stationName")
    }

    public func isEqual(to object: Any?) -> Bool {
      guard let object = object as? PCPOIGasStation else { return false }
      guard self.id == object.id else { return false }
      guard self.type == object.type else { return false }
      guard self.fuelPrices == object.fuelPrices else { return false }
      guard self.locationBasedApps == object.locationBasedApps else { return false }
      guard self.referenceStatuses == object.referenceStatuses else { return false }
      guard self.sucessorOf == object.sucessorOf else { return false }
      guard self.address == object.address else { return false }
      guard self.amenities == object.amenities else { return false }
      guard self.brand == object.brand else { return false }
      guard self.brandID == object.brandID else { return false }
      guard self.contact == object.contact else { return false }
      guard self.food == object.food else { return false }
      guard self.latitude == object.latitude else { return false }
      guard self.longitude == object.longitude else { return false }
      guard self.loyaltyPrograms == object.loyaltyPrograms else { return false }
      guard self.onlinePayment == object.onlinePayment else { return false }
      guard self.openingHours == object.openingHours else { return false }
      guard self.paymentMethods == object.paymentMethods else { return false }
      guard self.postalServices == object.postalServices else { return false }
      guard self.priceFormat == object.priceFormat else { return false }
      guard self.references == object.references else { return false }
      guard self.services == object.services else { return false }
      guard self.shopGoods == object.shopGoods else { return false }
      guard self.stationName == object.stationName else { return false }
      return true
    }

    public static func == (lhs: PCPOIGasStation, rhs: PCPOIGasStation) -> Bool {
        return lhs.isEqual(to: rhs)
    }
}
