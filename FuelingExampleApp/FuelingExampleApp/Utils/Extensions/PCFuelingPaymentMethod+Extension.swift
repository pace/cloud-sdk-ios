//
//  PCFuelingPaymentMethod+Extension.swift
//  FuelingExampleApp
//
//  Created by PACE Telematics GmbH.
//

import PACECloudSDK

extension PCFuelingPaymentMethod {
    var localizedKind: String? {
        guard let kind = kind else { return nil }
        return PCFuelingPaymentMethod.localizedKind(for: kind)
    }

    var isPayPal: Bool {
        kind == Constants.paypal
    }

    static func localizedKind(for kind: String) -> String {
        switch kind {
        case Constants.applepay:
            return "Apple Pay"

        case Constants.paypal:
            return "PayPal"

        case Constants.giropay:
            return "giropay"

        case Constants.creditcard:
            return "Credit card"

        default:
            return kind.capitalized
        }
    }
}
