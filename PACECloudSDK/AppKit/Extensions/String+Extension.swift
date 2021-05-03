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

        // we have no localization in current language
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

    static func randomHex(length: Int) -> String? {
        guard length > 0 else { return nil }

        var bytes = [UInt8](repeating: 0, count: length)
        let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)

        guard status == errSecSuccess else { return nil }

        let randomHex = bytes.reduce(into: "", { $0 += String(format: "%02X", $1) })
        return String(randomHex.prefix(length))
    }
}

extension StringProtocol {
    var firstUppercased: String { prefix(1).uppercased() + dropFirst() }
}
