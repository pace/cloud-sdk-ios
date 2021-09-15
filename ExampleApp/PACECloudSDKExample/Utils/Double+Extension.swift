//
//  Double+Extension.swift
//  PACECloudSDKExample
//
//  Created by PACE Telematics GmbH.
//

import Foundation

extension Double {
    func round(_ fractionDigits: Int) -> Double {
        let multiplier = pow(10, Double(fractionDigits))
        return Darwin.round(self * multiplier) / multiplier
    }

    func formattedDistance(fractionDigits: Int) -> String {
        let unit = self >= 1000 ? "km" : "m"
        let stringDistance: String

        let numberFormatter = NumberFormatter()
        numberFormatter.locale = .current
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = fractionDigits

        if self >= 1000 {
            let roundedDistance = (self / 1000).round(fractionDigits)
            stringDistance = (numberFormatter.string(from: NSNumber(value: roundedDistance)) ?? "")
        } else {
            stringDistance = "\(Int(self))"
        }

        return stringDistance + " " + unit
    }
}
