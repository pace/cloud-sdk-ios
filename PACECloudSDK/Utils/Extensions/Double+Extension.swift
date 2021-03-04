//
//  Double+Extension.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

extension Double {
    func round(_ fractionDigits: Int) -> Double {
        let multiplier = pow(10, Double(fractionDigits))
        return (self * multiplier).rounded() / multiplier
    }
}
