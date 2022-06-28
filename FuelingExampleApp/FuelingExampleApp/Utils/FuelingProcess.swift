//
//  FuelingProcess.swift
//  FuelingExampleApp
//
//  Created by PACE Telematics GmbH.
//

import Foundation
import PACECloudSDK

class FuelingProcess {
    var amount: Decimal?
    var fuelType: String?
    var fuelTypeName: String?
    var fuelingAmount: Decimal?
    var pricePerLiter: Decimal?
    var pin: String?

    private let twoDecimalsFormatter = PriceNumberFormatter(with: "d.dd")

    let gasStation: GasStation
    let prices: [PCFuelingFuelPrice]
    let pumps: [PCFuelingPump]
    let supportedPaymentMethods: [PCFuelingPaymentMethod]
    let unsupportedPaymentMethods: [PCFuelingPaymentMethod]

    var selectedPump: PCFuelingPump?
    var pumpInformation: PCFuelingPumpResponse? {
        didSet {
            self.amount = pumpInformation?.priceIncludingVAT
            self.fuelType = pumpInformation?.fuelType
            self.fuelTypeName = pumpInformation?.productName
            self.fuelingAmount = pumpInformation?.fuelAmount
            self.pricePerLiter = pumpInformation?.pricePerUnit
        }
    }

    var selectedPaymentMethod: PCFuelingPaymentMethod?

    var transactionId: String? {
        get { selectedPump?.transactionId }
        set { selectedPump?.transactionId = newValue }
    }

    var didAuthorizePreAuthAmount: Bool {
        selectedPump?.transactionId != nil
    }

    init(gasStation: GasStation,
         prices: [PCFuelingFuelPrice],
         pumps: [PCFuelingPump],
         supportedPaymentMethods: [PCFuelingPaymentMethod],
         unsupportedPaymentMethods: [PCFuelingPaymentMethod]) {
        self.gasStation = gasStation
        self.prices = prices
        self.pumps = pumps

        if let payPalPaymentMethod = supportedPaymentMethods.first(where: { $0.kind == Constants.paypal }) {
            self.supportedPaymentMethods = supportedPaymentMethods.filter { $0 != payPalPaymentMethod }
            self.unsupportedPaymentMethods = unsupportedPaymentMethods + [payPalPaymentMethod]
        } else {
            self.supportedPaymentMethods = supportedPaymentMethods
            self.unsupportedPaymentMethods = unsupportedPaymentMethods
        }
    }

    func resetPumpInformation() {
        selectedPump = nil
        pumpInformation = nil
    }

    func resetPaymentMethodInformation() {
        selectedPaymentMethod = nil
    }
}

// MARK: - Helpers

extension FuelingProcess {
    var currency: String {
        prices.first?.currency ?? Constants.fallbackCurrency
    }

    var currencySymbol: String {
        NSLocale.getSymbol(forCurrencyCode: currency)
    }

    var isPostPay: Bool {
        selectedPump?.fuelingProcess == .postPay
    }

    var isPreAuth: Bool {
        selectedPump?.fuelingProcess == .preAuth
    }

    var formattedAmount: String {
        guard let amount = amount else { return "" }
        return twoDecimalsFormatter.string(from: NSDecimalNumber(decimal: amount)) ?? ""
    }

    var formattedFuelingAmount: String {
        guard let fuelingAmount = fuelingAmount else { return "" }
        return twoDecimalsFormatter.string(from: NSDecimalNumber(decimal: fuelingAmount)) ?? ""
    }

    var formattedPricePerLiter: String {
        guard let pricePerLiter = pricePerLiter else { return "" }
        return PriceNumberFormatter(with: "d.ddd").string(from: NSNumber(value: pricePerLiter.toDouble)) ?? ""
    }

    func formattedDiscountedAmount(for discountAmount: Decimal) -> String {
        guard let amount = amount else { return "" }
        let discountedAmount = amount - discountAmount
        return twoDecimalsFormatter.string(from: NSDecimalNumber(decimal: discountedAmount)) ?? ""
    }

    func discountedAmount(for discountAmount: Decimal) -> Decimal? {
        guard let amount = amount else { return nil }
        let discountedAmount = amount - discountAmount
        return discountedAmount
    }
}
