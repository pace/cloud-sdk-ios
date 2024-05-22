//
// Generated by SwagGen
// https://github.com/pace/SwagGen
//

import Foundation

public class PCFuelingPumpResponse: APIModel {

    /** Type */
    public enum PCFuelingType: String, Codable, Equatable, CaseIterable {
        case pump = "pump"
    }

    /** The fueling process that has to be followed
    * `postPay` the pump is *free* and needs to be [paid](#operation/ProcessPayment) after fueling
    * `preAuth` the pump is *locked* and has to be [unlocked](#operation/ProcessPayment)
    * `preAuthWithFuelType` the pump is *locked* and has to be [unlocked](#operation/ProcessPayment), the `carFuelType` is required
     */
    public enum PCFuelingFuelingProcess: String, Codable, Equatable, CaseIterable {
        case postPay = "postPay"
        case preAuth = "preAuth"
        case preAuthWithFuelType = "preAuthWithFuelType"
    }

    /** Current pump status.
    * `free` the pump is free, fueling possible (nozzle not lifted), possible transitions *inUse*, *locked*, *outOfOrder*. Note: A transition from *free* to *locked* may implies the pump was pre-authorization was canceled.
    * `inUse` the pump is fueling, possible transitions *readyToPay*, *locked*, *outOfOrder*
    * `readyToPay` the pump can be payed using the post pay process, possible transitions *free*, *locked*, *outOfOrder*. Note: A transition from *readyToPay* to *free* implies the pump was paid.
    * `locked` the pump required a pre-authorization, possible transitions *free*, *inTransaction*, *outOfOrder*. Note: A transition from *locked* to *free* implies the pre-authorization was successful.
    * `inTransaction` the pump is in use by another user using the pre-authorization process, possible transitions *locked*, *outOfOrder*
    * `outOfOrder` the pump has a technical problem, this can only be resolved by the gas station staff on site, possible transitions *free*, *locked*. Note: The customer has to pay in the shop
     */
    public enum PCFuelingStatus: String, Codable, Equatable, CaseIterable {
        case free = "free"
        case inUse = "inUse"
        case readyToPay = "readyToPay"
        case locked = "locked"
        case inTransaction = "inTransaction"
        case outOfOrder = "outOfOrder"
    }

    /** Pump ID */
    public var id: ID?

    /** Type */
    public var type: PCFuelingType?

    public var vat: VAT?

    /** Only if status is locked: available fuel products at the given pump */
    public var availableProducts: [PCFuelingProduct]?

    /** Currency as specified in ISO-4217. */
    public var currency: String?

    /** Fuel amount in units */
    public var fuelAmount: Decimal?

    public var fuelType: String?

    /** The fueling process that has to be followed
* `postPay` the pump is *free* and needs to be [paid](#operation/ProcessPayment) after fueling
* `preAuth` the pump is *locked* and has to be [unlocked](#operation/ProcessPayment)
* `preAuthWithFuelType` the pump is *locked* and has to be [unlocked](#operation/ProcessPayment), the `carFuelType` is required
 */
    public var fuelingProcess: PCFuelingFuelingProcess?

    /** Pump identifier */
    public var identifier: String?

    public var priceIncludingVAT: Decimal?

    /** Fuel price in currency/unit */
    public var pricePerUnit: Decimal?

    public var priceWithoutVAT: Decimal?

    public var productName: String?

    /** Only if status is locked or readyToPay: PRNs required for creating a token for payment at this gas station */
    public var purposePRNs: [String]?

    /** Current pump status.
* `free` the pump is free, fueling possible (nozzle not lifted), possible transitions *inUse*, *locked*, *outOfOrder*. Note: A transition from *free* to *locked* may implies the pump was pre-authorization was canceled.
* `inUse` the pump is fueling, possible transitions *readyToPay*, *locked*, *outOfOrder*
* `readyToPay` the pump can be payed using the post pay process, possible transitions *free*, *locked*, *outOfOrder*. Note: A transition from *readyToPay* to *free* implies the pump was paid.
* `locked` the pump required a pre-authorization, possible transitions *free*, *inTransaction*, *outOfOrder*. Note: A transition from *locked* to *free* implies the pre-authorization was successful.
* `inTransaction` the pump is in use by another user using the pre-authorization process, possible transitions *locked*, *outOfOrder*
* `outOfOrder` the pump has a technical problem, this can only be resolved by the gas station staff on site, possible transitions *free*, *locked*. Note: The customer has to pay in the shop
 */
    public var status: PCFuelingStatus?

    public var transaction: PCFuelingTransaction?

    /** Provided if the user pre-authorized the pump */
    public var transactionId: ID?

    /** Fuel measurement unit. Eg: `liter`, `us-gallon`, `uk-gallon`, `kilogram` */
    public var unit: String?

    public class VAT: APIModel {

        public var amount: Decimal?

        public var rate: Decimal?

        public init(amount: Decimal? = nil, rate: Decimal? = nil) {
            self.amount = amount
            self.rate = rate
        }

        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: StringCodingKey.self)

            amount = try container.decodeLosslessDecimal("amount")
            rate = try container.decodeLosslessDecimal("rate")
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: StringCodingKey.self)

            try container.encodeIfPresent(amount, forKey: "amount")
            try container.encodeIfPresent(rate, forKey: "rate")
        }

        public func isEqual(to object: Any?) -> Bool {
          guard let object = object as? VAT else { return false }
          guard self.amount == object.amount else { return false }
          guard self.rate == object.rate else { return false }
          return true
        }

        public static func == (lhs: VAT, rhs: VAT) -> Bool {
            return lhs.isEqual(to: rhs)
        }
    }

    public init(id: ID? = nil, type: PCFuelingType? = nil, vat: VAT? = nil, availableProducts: [PCFuelingProduct]? = nil, currency: String? = nil, fuelAmount: Decimal? = nil, fuelType: String? = nil, fuelingProcess: PCFuelingFuelingProcess? = nil, identifier: String? = nil, priceIncludingVAT: Decimal? = nil, pricePerUnit: Decimal? = nil, priceWithoutVAT: Decimal? = nil, productName: String? = nil, purposePRNs: [String]? = nil, status: PCFuelingStatus? = nil, transaction: PCFuelingTransaction? = nil, transactionId: ID? = nil, unit: String? = nil) {
        self.id = id
        self.type = type
        self.vat = vat
        self.availableProducts = availableProducts
        self.currency = currency
        self.fuelAmount = fuelAmount
        self.fuelType = fuelType
        self.fuelingProcess = fuelingProcess
        self.identifier = identifier
        self.priceIncludingVAT = priceIncludingVAT
        self.pricePerUnit = pricePerUnit
        self.priceWithoutVAT = priceWithoutVAT
        self.productName = productName
        self.purposePRNs = purposePRNs
        self.status = status
        self.transaction = transaction
        self.transactionId = transactionId
        self.unit = unit
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StringCodingKey.self)

        id = try container.decodeIfPresent("id")
        type = try container.decodeIfPresent("type")
        vat = try container.decodeIfPresent("VAT")
        availableProducts = try container.decodeArrayIfPresent("availableProducts")
        currency = try container.decodeIfPresent("currency")
        fuelAmount = try container.decodeLosslessDecimal("fuelAmount")
        fuelType = try container.decodeIfPresent("fuelType")
        fuelingProcess = try container.decodeIfPresent("fuelingProcess")
        identifier = try container.decodeIfPresent("identifier")
        priceIncludingVAT = try container.decodeLosslessDecimal("priceIncludingVAT")
        pricePerUnit = try container.decodeLosslessDecimal("pricePerUnit")
        priceWithoutVAT = try container.decodeLosslessDecimal("priceWithoutVAT")
        productName = try container.decodeIfPresent("productName")
        purposePRNs = try container.decodeArrayIfPresent("purposePRNs")
        status = try container.decodeIfPresent("status")
        transaction = try container.decodeIfPresent("transaction")
        transactionId = try container.decodeIfPresent("transactionId")
        unit = try container.decodeIfPresent("unit")
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StringCodingKey.self)

        try container.encodeIfPresent(id, forKey: "id")
        try container.encodeIfPresent(type, forKey: "type")
        try container.encodeIfPresent(vat, forKey: "VAT")
        try container.encodeIfPresent(availableProducts, forKey: "availableProducts")
        try container.encodeIfPresent(currency, forKey: "currency")
        try container.encodeIfPresent(fuelAmount, forKey: "fuelAmount")
        try container.encodeIfPresent(fuelType, forKey: "fuelType")
        try container.encodeIfPresent(fuelingProcess, forKey: "fuelingProcess")
        try container.encodeIfPresent(identifier, forKey: "identifier")
        try container.encodeIfPresent(priceIncludingVAT, forKey: "priceIncludingVAT")
        try container.encodeIfPresent(pricePerUnit, forKey: "pricePerUnit")
        try container.encodeIfPresent(priceWithoutVAT, forKey: "priceWithoutVAT")
        try container.encodeIfPresent(productName, forKey: "productName")
        try container.encodeIfPresent(purposePRNs, forKey: "purposePRNs")
        try container.encodeIfPresent(status, forKey: "status")
        try container.encodeIfPresent(transaction, forKey: "transaction")
        try container.encodeIfPresent(transactionId, forKey: "transactionId")
        try container.encodeIfPresent(unit, forKey: "unit")
    }

    public func isEqual(to object: Any?) -> Bool {
      guard let object = object as? PCFuelingPumpResponse else { return false }
      guard self.id == object.id else { return false }
      guard self.type == object.type else { return false }
      guard self.vat == object.vat else { return false }
      guard self.availableProducts == object.availableProducts else { return false }
      guard self.currency == object.currency else { return false }
      guard self.fuelAmount == object.fuelAmount else { return false }
      guard self.fuelType == object.fuelType else { return false }
      guard self.fuelingProcess == object.fuelingProcess else { return false }
      guard self.identifier == object.identifier else { return false }
      guard self.priceIncludingVAT == object.priceIncludingVAT else { return false }
      guard self.pricePerUnit == object.pricePerUnit else { return false }
      guard self.priceWithoutVAT == object.priceWithoutVAT else { return false }
      guard self.productName == object.productName else { return false }
      guard self.purposePRNs == object.purposePRNs else { return false }
      guard self.status == object.status else { return false }
      guard self.transaction == object.transaction else { return false }
      guard self.transactionId == object.transactionId else { return false }
      guard self.unit == object.unit else { return false }
      return true
    }

    public static func == (lhs: PCFuelingPumpResponse, rhs: PCFuelingPumpResponse) -> Bool {
        return lhs.isEqual(to: rhs)
    }
}
