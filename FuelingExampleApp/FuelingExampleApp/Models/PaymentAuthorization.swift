//
//  PaymentAuthorization.swift
//  FuelingExampleApp
//
//  Created by PACE Telematics GmbH.
//

import Foundation

struct PaymentAuthorization {
    let otp: String
    let method: String
}

enum PaymentAuthorizationType: String {
    case pin
    case password
    case biometry
}
