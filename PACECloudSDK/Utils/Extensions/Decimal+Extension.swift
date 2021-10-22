//
//  Decimal+Extension.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

public extension Decimal {
    var toString: String {
        NSDecimalNumber(decimal: self).stringValue
    }

    var toDouble: Double {
        NSDecimalNumber(decimal: self).doubleValue
    }
}
