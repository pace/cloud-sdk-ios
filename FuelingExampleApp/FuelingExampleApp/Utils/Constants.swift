//
//  Constants.swift
//  FuelingExampleApp
//
//  Created by PACE Telematics GmbH.
//

import Foundation

enum Constants {
    static let fallbackCurrency = "EUR"
    static let paceRecipient: String = "PACE Telematics GmbH"

    static let prnPrefixGasStationId: String = "prn:poi:gas-stations:"
    static let prnPrefixFuelType: String = "prn:cms:fuels:"
    static let prnPrefixRiskId: String = "prn:paypal:risk-correlation-ids:"

    static let paypal: String = "paypal"
    static let applepay: String = "applepay"
    static let giropay: String = "giropay"
    static let creditcard: String = "creditcard"

    static var apiBaseURL: String {
        #if PRODUCTION
        return "https://api.pace.cloud"
        #elseif DEVELOPMENT
        return "https://api.dev.pace.cloud"
        #elseif SANDBOX
        return "https://api.sandbox.pace.cloud"
        #endif
    }

    static let genericErrorMessage: String = "Oops, something went wrong."
    static let networkErrorMessage: String = "Your network seems to be unstable."
}
