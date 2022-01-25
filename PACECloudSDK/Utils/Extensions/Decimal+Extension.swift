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

extension Decimal {
    /// Returns the number of decimal places
    /// https://stackoverflow.com/questions/41744278/count-number-of-decimal-places-in-a-float-or-decimal-in-swift
    var significantFractionalDecimalDigits: Int {
        return max(-exponent, 0)
    }
}
