//
//  BiometryTOTPData.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

public extension IDKit {
    struct BiometryTOTPData: Codable {
        public let secret: String
        public let period: Double
        public let digits: Int
        public let algorithm: String

        public init?(from attributes: PCUserDeviceTOTP.Attributes) {
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
}
