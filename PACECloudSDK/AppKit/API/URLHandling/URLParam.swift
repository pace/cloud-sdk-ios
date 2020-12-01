//
//  URLParam.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

enum URLParam: String {
    case amount
    case currency
    case paymentMethod = "payment_method_name"
    case paymentMethodKind = "payment_method_kind"
    case purposeText = "purpose_text"
    case recipient
    case redirectUri = "redirect_uri"
    case state
    case status = "status_code"
    case references = "r"
    case vin
    case mileage
    case expectedAmount = "expected_amount"
    case fuelType = "fuel_type"
    case until

    case reopenUrl = "reopen_url"
    case reopenTitle = "reopen_title"
    case reopenSubtitle = "reopen_subtitle"

    case accessToken = "access_token"

    static var appStartUrlParams: [URLParam] {
        return [.references, .vin, .mileage, .expectedAmount, .fuelType]
    }
}
