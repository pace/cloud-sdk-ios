//
//  PACECloudSDK+URL.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

public extension PACECloudSDK {
    enum URL {
        case paceID
        case payment
        case transactions
        case dashboard
        case fueling(id: String?)

        public init?(rawValue: String) {
            switch rawValue {
            case "paceID":
                self = .paceID

            case "payment":
                self = .payment

            case "transactions":
                self = .transactions

            case "dashboard":
                self = .dashboard

            default:
                return nil
            }
        }

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

            case .dashboard:
                return "https://my\(shortValue).fuel.site"

            case .fueling(id: let id):
                return buildFuelingUrl(with: id)
            }
        }

        private func buildFuelingUrl(with id: String?) -> String {
            let currentEnvironment = PACECloudSDK.shared.environment
            let environmentPrefix = currentEnvironment == .production ? "" : "\(currentEnvironment.short)."
            var baseUrl = "https://\(environmentPrefix)fuel.site"

            if let id = id {
                baseUrl += "?r=\(id)"
            }

            return baseUrl
        }
    }
}
