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

        public init?(from data: PCUserDeviceTOTP) {
            guard let secret = data.secret,
                  let period = data.period,
                  let digits = data.digits,
                  let algorithm = data.algorithm?.rawValue else { return nil }

            self.secret = secret
            self.period = Double(period)
            self.digits = digits
            self.algorithm = algorithm
        }
    }
}
