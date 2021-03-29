//
//  BiometryTOTPData.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

struct BiometryTOTPData: Codable {
    private enum TOTPURLParam: String {
        case secret
        case period
        case digits
        case algorithm
    }

    let secret: String
    let period: Double
    let digits: Int
    let algorithm: String

    init?(from attributes: PCUserDeviceTOTP.Attributes) {
        guard let secret = attributes.secret,
              let period = attributes.period,
              let digits = attributes.digits,
              let algorithm = attributes.algorithm?.rawValue else { return nil }

        self.secret = secret
        self.period = Double(period)
        self.digits = digits
        self.algorithm = algorithm
    }
}
