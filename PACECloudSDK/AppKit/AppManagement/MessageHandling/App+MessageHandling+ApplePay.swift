//
//  App+ApplePay.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation
import PassKit

extension App {
    func handleApplePayAvailabilityCheck(with request: API.Communication.ApplePayAvailabilityCheckRequest,
                                         completion: @escaping (API.Communication.ApplePayAvailabilityCheckResult) -> Void) {
        let networks: [PKPaymentNetwork] = paymentNetworks(for: request.supportedNetworks)
        let result = networks.isEmpty ? PKPaymentAuthorizationController.canMakePayments() : PKPaymentAuthorizationController.canMakePayments(usingNetworks: networks)

        completion(.init(.init(response: .init(isAvailable: result))))
    }

    private func paymentNetworks(for supportedNetworks: [String]) -> [PKPaymentNetwork] {
        var paymentNetworks: [PKPaymentNetwork] = []

        if #available(iOS 14.0, *) {
            paymentNetworks.append(contentsOf: [.barcode, .girocard])
        }

        if #available(iOS 12.1.1, *) {
            paymentNetworks.append(contentsOf: [.vPay, .maestro, .mada, .elo, .electron, .eftpos])
        }

        if #available(iOS 11.2, *) {
            paymentNetworks.append(.cartesBancaires)
        }

        paymentNetworks.append(contentsOf: [.amex, .chinaUnionPay, .discover, .idCredit, .interac, .JCB, .masterCard, .privateLabel, .quicPay, .suica, .visa])

        let matchingNetworks = paymentNetworks.filter { paymentNetwork in
            supportedNetworks.contains(where: { $0.lowercased() == paymentNetwork.rawValue.lowercased() })
        }

        return matchingNetworks
    }
}
