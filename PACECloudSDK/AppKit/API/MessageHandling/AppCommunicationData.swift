//
//  AppCommunicationData.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation
import PassKit

public extension AppKit {
    enum GetAccessTokenReason: String {
        case unauthorized
        case other
    }

    enum BiometryMethod: String {
        case other, face, fingerprint
    }

    struct LogoutResponse: Codable {
        let statusCode: HttpStatusCode

        public init(statusCode: HttpStatusCode) {
            self.statusCode = statusCode
        }
    }
}

public extension API.Communication.PaymentMethod {
    init(displayName: String?, network: String?, type: PKPaymentMethodType) {
        let displayName = displayName
        let network = network
        let type: String = {
            switch type {
            case .credit:
                return "credit"

            case .debit:
                return "debit"

            case .prepaid:
                return "prepaid"

            case .store:
                return "store"

            case .unknown:
                return "unknown"

            @unknown default:
                return "undefined"
            }
        }()

        self.init(displayName: displayName, network: network, type: type)
    }
}
