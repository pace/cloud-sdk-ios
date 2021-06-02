//
//  App+ApplePay.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation
import PassKit

extension App {
    func handleApplePayAvailibilityCheck(with request: AppKit.AppRequestData<String>) {
        let supportedNetworks = request.message.split(separator: ",").map { String($0) }
        let networks: [PKPaymentNetwork] = paymentNetworks(for: supportedNetworks)
        let result = networks.isEmpty ? PKPaymentAuthorizationController.canMakePayments() : PKPaymentAuthorizationController.canMakePayments(usingNetworks: networks)

        messageInterceptor?.respond(id: request.id, message: result)
    }

    func handleApplePayPaymentRequest(with request: AppKit.AppRequestData<AppKit.ApplePayRequest>, completion: @escaping () -> Void) {
        AppKit.shared.notifyMerchantIdentifier { [weak self] merchantIdentifier in
            guard !merchantIdentifier.isEmpty,
                  let applePayRequest = self?.paymentRequest(for: merchantIdentifier, with: request.message) else {
                self?.messageInterceptor?.send(id: request.id, error: .internalError)
                completion()
                return
            }

            AppKit.shared.notifyApplePayRequest(with: applePayRequest) { [weak self] response in
                guard let response = response else {
                    self?.messageInterceptor?.send(id: request.id, error: .internalError)
                    completion()
                    return
                }

                self?.messageInterceptor?.respond(id: request.id, message: response)
                completion()
            }
        }
    }

    private func paymentRequest(for merchantIdentifier: String, with request: AppKit.ApplePayRequest) -> PKPaymentRequest {
        let paymentRequest = PKPaymentRequest()
        paymentRequest.countryCode = request.countryCode
        paymentRequest.currencyCode = request.currencyCode
        paymentRequest.merchantIdentifier = merchantIdentifier

        paymentRequest.merchantCapabilities = retrieveMerchantCapabilities(request)
        paymentRequest.shippingType = retrieveShippingType(request)
        paymentRequest.requiredBillingContactFields = .init()
        paymentRequest.requiredShippingContactFields = .init()
        paymentRequest.paymentSummaryItems = [PKPaymentSummaryItem(label: request.total.label,
                                                                   amount: NSDecimalNumber(string: request.total.amount),
                                                                   type: request.total.type == "final" ? .final : .pending)]

        paymentRequest.supportedNetworks = paymentNetworks(for: request.supportedNetworks)
        return paymentRequest
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

    private func retrieveShippingType(_ request: AppKit.ApplePayRequest) -> PKShippingType {
        return {
            switch request.shippingType {
            case "servicePickup":
                return .servicePickup

            case "delivery":
                return .delivery

            case "shipping":
                return .shipping

            case "storePickup":
                return .storePickup

            default:
                return .servicePickup
            }
        }()
    }

    private func retrieveMerchantCapabilities(_ request: AppKit.ApplePayRequest) -> PKMerchantCapability {
        var merchantCapabilities: PKMerchantCapability = .init()

        request.merchantCapabilities.forEach {
            switch $0 {
            case "supports3DS":
                merchantCapabilities.insert(.capability3DS)

            case "supportsCredit":
                merchantCapabilities.insert(.capabilityCredit)

            case "supportsDebit":
                merchantCapabilities.insert(.capabilityDebit)

            case "supportsEMV":
                merchantCapabilities.insert(.capabilityEMV)

            default:
                break
            }
        }

        return merchantCapabilities
    }
}
