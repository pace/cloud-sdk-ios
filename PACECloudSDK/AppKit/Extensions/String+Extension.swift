//
//  String+Extension.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

extension String {
    func matches(_ regex: String, isCaseSensitive: Bool = true) -> Bool {
        var options: String.CompareOptions = [.regularExpression]

        if !isCaseSensitive {
            options.insert(.caseInsensitive)
        }

        return self.range(of: regex, options: options, range: nil, locale: nil) != nil
    }

    func matches(for regex: String) -> [String]? {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: self, range: NSRange(self.startIndex..., in: self))
            return results.compactMap {
                guard let range = Range($0.range, in: self) else { return nil }
                return String(self[range])
            }
        } catch {
            return nil
        }
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
