//
//  String+Extension.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

private var fallbackLocalizationBundle: Bundle?

/* Localization */
extension String {
    static func localizedPaymentMethodKind(for kind: String) -> String {
        let paymentMethodKind = "payment.method.kind.\(kind)".localized
        return paymentMethodKind.isEmpty ? kind : paymentMethodKind
    }
    private func localized(_ tableName: String? = nil, bundle: Bundle, value: String = "", comment: String = "") -> String {
        var localizedString = NSLocalizedString(self, tableName: tableName, bundle: bundle, value: value, comment: comment)

        // we have no localization in current language????
        if localizedString == self || localizedString.isEmpty {

            // make sure we have a fallback bundle loaded
            if fallbackLocalizationBundle == nil {
                if let fallbackLanguage = Bundle.main.infoDictionary?["CFBundleDevelopmentRegion"] as? String,
                   let fallbackBundlePath = Bundle.main.path(forResource: fallbackLanguage, ofType: "lproj") {
                    fallbackLocalizationBundle = Bundle(path: fallbackBundlePath)
                }
            }

            // get a default localization if available
            if let fallbackString = fallbackLocalizationBundle?.localizedString(forKey: self, value: value, table: tableName) {
                localizedString = fallbackString
            }
        }

        return localizedString
    }

    var localized: String {
        return self.localized(bundle: Bundle.paceCloudSDK)
    }
}

extension String {
    func matches(_ regex: String, isCaseSensitive: Bool = true) -> Bool {
        var options: String.CompareOptions = [.regularExpression]

        if !isCaseSensitive {
            options.insert(.caseInsensitive)
        }

        return self.range(of: regex, options: options, range: nil, locale: nil) != nil
    }

    func conformsToURN() -> Bool {
        let regex = "[a-z0-9][a-z0-9-]{0,31}:[a-z0-9()+,\\-.:=@;$_!*'%/?#]+"
        return self.matches(regex, isCaseSensitive: false)
    }
}
