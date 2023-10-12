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

        paymentNetworks.append(contentsOf: [
            .barcode,
            .girocard,
            .amex,
            .cartesBancaires,
            .chinaUnionPay,
            .discover,
            .eftpos,
            .electron,
            .elo,
            .idCredit,
            .interac,
            .JCB,
            .mada,
            .maestro,
            .masterCard,
            .privateLabel,
            .quicPay,
            .suica,
            .visa,
            .vPay
        ])

        let matchingNetworks = paymentNetworks.filter { paymentNetwork in
            supportedNetworks.contains(where: { $0.lowercased() == paymentNetwork.rawValue.lowercased() })
        }

        return matchingNetworks
    }
}
