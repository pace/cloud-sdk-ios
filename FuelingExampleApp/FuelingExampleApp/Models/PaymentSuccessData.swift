//
//  PaymentSuccessData.swift
//  FuelingExampleApp
//
//  Created by PACE Telematics GmbH.
//

import Foundation

struct PaymentSuccessData {
    let actualAmount: Decimal?
    let fuelingAmount: Decimal?
    let pricePerUnit: Decimal?
    let productName: String?
    let currencySymbol: String?
    let discountAmount: Decimal?
    let discountedAmount: Decimal?
    let paymentMethod: String?
    let recipient: String?

    private let twoDecimalsFormatter = PriceNumberFormatter(with: "d.dd")

    var formattedAmount: String? {
        guard let actualAmount = actualAmount else { return nil }
        return twoDecimalsFormatter.string(from: NSDecimalNumber(decimal: actualAmount))
    }

    var formattedFuelingAmount: String? {
        guard let fuelingAmount = fuelingAmount else { return nil }
        return twoDecimalsFormatter.string(from: NSDecimalNumber(decimal: fuelingAmount))
    }

    var formattedPricePerUnit: String? {
        guard let pricePerUnit = pricePerUnit else { return nil }
        return PriceNumberFormatter(with: "d.ddd").string(from: NSDecimalNumber(decimal: pricePerUnit))
    }

    var formattedDiscountAmount: String? {
        guard let discountAmount = discountAmount else { return nil }
        return twoDecimalsFormatter.string(from: NSDecimalNumber(decimal: discountAmount))
    }

    var formattedDiscountedAmount: String? {
        guard let discountedAmount = discountedAmount else { return nil }
        return twoDecimalsFormatter.string(from: NSDecimalNumber(decimal: discountedAmount))
    }

    init() {
        self.actualAmount = nil
        self.fuelingAmount = nil
        self.pricePerUnit = nil
        self.productName = nil
        self.currencySymbol = nil
        self.discountAmount = nil
        self.discountedAmount = nil
        self.paymentMethod = nil
        self.recipient = nil
    }

    init(actualAmount: Decimal?,
         fuelingAmount: Decimal?,
         productName: String?,
         pricePerUnit: Decimal? = nil,
         currencySymbol: String? = nil,
         discountAmount: Decimal? = nil,
         discountedAmount: Decimal? = nil,
         paymentMethod: String? = nil,
         recipient: String? = nil) {
        self.actualAmount = actualAmount
        self.fuelingAmount = fuelingAmount
        self.pricePerUnit = pricePerUnit
        self.productName = productName
        self.currencySymbol = currencySymbol
        self.discountAmount = discountAmount
        self.discountedAmount = discountedAmount
        self.paymentMethod = paymentMethod
        self.recipient = recipient
    }
}
