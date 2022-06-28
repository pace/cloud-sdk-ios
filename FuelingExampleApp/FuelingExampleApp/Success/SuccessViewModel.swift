//
//  SuccessViewModel.swift
//  FuelingExampleApp
//
//  Created by PACE Telematics GmbH.
//

import Foundation
import PACECloudSDK

protocol SuccessViewModel: AnyObject {
    var summaryItems: LiveData<[SummaryItem]> { get }
    init(paymentSuccessData: PaymentSuccessData)
}

class SuccessViewModelImplementation: SuccessViewModel {
    private(set) var summaryItems: LiveData<[SummaryItem]> = .init()
    private let paymentSuccessData: PaymentSuccessData

    required init(paymentSuccessData: PaymentSuccessData) {
        self.paymentSuccessData = paymentSuccessData
        setupSummaryItems()
    }

    private func setupSummaryItems() {
        guard let productName = paymentSuccessData.productName,
              let formattedFuelingAmount = paymentSuccessData.formattedFuelingAmount,
              let pricePerUnit = paymentSuccessData.formattedPricePerUnit,
              let amount = paymentSuccessData.formattedAmount,
              let currencySymbol = paymentSuccessData.currencySymbol else { return }

        var items: [SummaryItem] = [
            .init(title: "Total amount", value: "\(amount)\(currencySymbol)")
        ]

        if let formattedDiscountedAmount = paymentSuccessData.formattedDiscountedAmount {
            let discountedAmount = "\(formattedDiscountedAmount)\(currencySymbol)"
            items.append(.init(title: "Discounted amount", value: discountedAmount))
        }

        let fuelingAmount = "\(formattedFuelingAmount) ltr"
        items.append(.init(title: productName, value: fuelingAmount))
        items.append(.init(title: "Price/ltr", value: "\(pricePerUnit)\(currencySymbol)"))

        if let paymentMethod = paymentSuccessData.paymentMethod {
            items.append(.init(title: "Payment method", value: paymentMethod))
        }

        if let recipient = paymentSuccessData.recipient {
            items.append(.init(title: "Recipient", value: recipient))
        }

        summaryItems.value = items
    }
}
