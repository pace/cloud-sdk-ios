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

    func handleApplePayRequest(with request: API.Communication.ApplePayRequestRequest, completion: @escaping (API.Communication.ApplePayRequestResult) -> Void) {
        AppKit.shared.notifyMerchantIdentifier { [weak self] merchantIdentifier in
            guard !merchantIdentifier.isEmpty,
                  let applePayRequest = self?.paymentRequest(for: merchantIdentifier, with: request) else {
                completion(.init(.init(statusCode: .internalServerError, response: .init(message: "Couldn't create a valid 'PKPaymentRequest'."))))
                return
            }

            AppKit.shared.notifyApplePayRequest(with: applePayRequest) { response in
                guard let response = response else {
                    completion(.init(.init(statusCode: .internalServerError, response: .init(message: "The payment request couldn't be processed correctly be the client."))))
                    return
                }

                completion(.init(.init(response: response)))
            }
        }
    }

    private func paymentRequest(for merchantIdentifier: String, with request: API.Communication.ApplePayRequestRequest) -> PKPaymentRequest {
        let paymentRequest = PKPaymentRequest()
        paymentRequest.countryCode = request.countryCode
        paymentRequest.currencyCode = request.currencyCode
        paymentRequest.merchantIdentifier = merchantIdentifier

        paymentRequest.merchantCapabilities = retrieveMerchantCapabilities(request)
        paymentRequest.shippingType = retrieveShippingType(request)
        paymentRequest.requiredBillingContactFields = retrieveContactFields(request.requiredBillingContactFields)
        paymentRequest.requiredShippingContactFields = retrieveContactFields(request.requiredShippingContactFields)
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

    private func retrieveShippingType(_ request: API.Communication.ApplePayRequestRequest) -> PKShippingType {
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

    private func retrieveMerchantCapabilities(_ request: API.Communication.ApplePayRequestRequest) -> PKMerchantCapability {
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

    private func retrieveContactFields(_ fields: [String]) -> Set<PKContactField> {
        var contactFields: Set<PKContactField> = .init()

        fields.forEach {
            switch $0 {
            case "postalAddress":
                contactFields.insert(.postalAddress)

            case "emailAddress":
                contactFields.insert(.emailAddress)

            case "phoneNumber":
                contactFields.insert(.phoneNumber)

            case "name":
                contactFields.insert(.name)

            case "phoneticName":
                contactFields.insert(.phoneticName)

            default:
                break
            }
        }

        return contactFields
    }
}
