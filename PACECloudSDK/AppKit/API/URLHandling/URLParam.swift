//
//  URLParam.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

enum URLParam: String {
    case redirectUri = "redirect_uri"
    case state
    case status = "status_code"
    case references = "r"
    case vin
    case mileage
    case expectedAmount = "expected_amount"
    case fuelType = "fuel_type"

    case accessToken = "access_token"

    static var appStartUrlParams: [URLParam] {
        return [.references, .vin, .mileage, .expectedAmount, .fuelType]
    }
}
