//
//  PACECloudSDK+URL.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

public extension PACECloudSDK {
    enum URL: String {
        case paceID
        case payment
        case transactions

        public var absoluteString: String {
            let currentEnvironment = PACECloudSDK.shared.environment
            let shortValue = currentEnvironment == .production ? "" : ".\(currentEnvironment.short)"

            switch self {
            case .paceID:
                return "https://id\(shortValue).pace.cloud"

            case .payment:
                return "https://pay\(shortValue).pace.cloud"

            case .transactions:
                return "\(URL.payment.absoluteString)/transactions"
            }
        }
    }
}
