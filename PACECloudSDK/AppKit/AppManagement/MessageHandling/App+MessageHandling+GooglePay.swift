//
//  App+MessageHandling+GooglePay.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

extension App {
    func handleGooglePayAvailabilityCheck(with request: API.Communication.GooglePayAvailabilityCheckRequest,
                                          completion: @escaping (API.Communication.GooglePayAvailabilityCheckResult) -> Void) {
        completion(.init(.init(statusCode: .internalServerError, response: .init(message: "GooglePay not implemented on iOS"))))
    }

    func handleGooglePayPayment(with request: API.Communication.GooglePayPaymentRequest,
                                completion: @escaping (API.Communication.GooglePayPaymentResult) -> Void) {
        completion(.init(.init(statusCode: .internalServerError, response: .init(message: "GooglePay not implemented on iOS"))))
    }
}
