//
//  PaymentConfirmationData.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

struct PaymentConfirmationData: BaseQueryParams {
    enum StatusCode: Int {
        case success = 200
        case canceled = 499

        init(paymentResult: PaymentConfirmationViewController.PaymentConfirmationResult) {
            if paymentResult == .success {
                self = .success
            } else {
                self = .canceled
            }
        }
    }

    let price: Float
    let currency: String
    let account: String
    let paymentMethodKind: String
    let redirectUri: String
    let state: String
    let recipient: String
    let purpose: String

    var host: String = ""
    var statusCode: Int? = StatusCode.canceled.rawValue

    init?(from query: String) {
        let queryItems = URLDecomposer.decomposeQuery(query)
        self.init(from: queryItems)
    }

    init?(from queryItems: [String: String]) {
        guard let amount = Float(queryItems[URLParam.amount.rawValue] ?? ""),
            let redirectUri = queryItems[URLParam.redirectUri.rawValue],
            let state = queryItems[URLParam.state.rawValue] else { return nil }

        self.price = amount
        self.redirectUri = redirectUri
        self.state = state
        self.currency = queryItems[URLParam.currency.rawValue] ?? "EUR"
        self.account = queryItems[URLParam.paymentMethod.rawValue] ?? "My Account"
        self.recipient = queryItems[URLParam.recipient.rawValue] ?? "Recipient"
        self.purpose = queryItems[URLParam.purposeText.rawValue] ?? "Purpose"
        self.paymentMethodKind = queryItems[URLParam.paymentMethodKind.rawValue] ?? "PaymentMethod"
    }
}
