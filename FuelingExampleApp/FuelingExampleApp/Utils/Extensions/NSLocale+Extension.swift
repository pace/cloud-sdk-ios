//
//  NSLocale+Extension.swift
//  FuelingExampleApp
//
//  Created by PACE Telematics GmbH.
//

import Foundation

extension NSLocale {
    static func getSymbol(forCurrencyCode code: String) -> String {
        let locale = NSLocale(localeIdentifier: code)
        if locale.displayName(forKey: .currencySymbol, value: code) == code {
            let newlocale = NSLocale(localeIdentifier: code.dropLast() + "_en")
            return newlocale.displayName(forKey: .currencySymbol, value: code) ?? ""
        }
        return locale.displayName(forKey: .currencySymbol, value: code) ?? ""
    }
}
