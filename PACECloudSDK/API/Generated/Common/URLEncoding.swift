//
//  URLEncoding.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

enum APIRequestError: Error {
    case encodingURL
}

extension CharacterSet { // Got it from Alamofire, because swift CharacterSet includes colons
    /// Creates a CharacterSet from RFC 3986 allowed characters.
    ///
    /// RFC 3986 states that the following characters are "reserved" characters.
    ///
    /// - General Delimiters: ":", "#", "[", "]", "@", "?", "/"
    /// - Sub-Delimiters: "!", "$", "&", "'", "(", ")", "*", "+", ",", ";", "="
    ///
    /// In RFC 3986 - Section 3.4, it states that the "?" and "/" characters should not be escaped to allow
    /// query strings to include a URL. Therefore, all "reserved" characters with the exception of "?" and "/"
    /// should be percent-escaped in the query string.
    public static let apiURLQueryAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        let encodableDelimiters = CharacterSet(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")

        return CharacterSet.urlQueryAllowed.subtracting(encodableDelimiters)
    }()
}

struct URLEncoding {
    static func encodeParams(_ params: [String: Any]) -> [(String, String)]  {
        var components: [(String, String)] = []
        for (key, value) in params {
            switch value {
            case let dictionary as [String: Any]:
                for (nestedKey, value) in dictionary {
                    components += queryComponents(fromKey: "\(key)[\(nestedKey)]", value: value)
                }
            case let array as [Any]:
                for value in array {
                    components += queryComponents(fromKey: "\(key)[]", value: value)
                }
            case let number as NSNumber:
                components.append((key.addingPercentEncoding(withAllowedCharacters: .apiURLQueryAllowed) ?? key,
                                   "\(number)".addingPercentEncoding(withAllowedCharacters: .apiURLQueryAllowed)
                                    ?? "\(number)"))
            case let bool as Bool:
                components.append((key.addingPercentEncoding(withAllowedCharacters: .apiURLQueryAllowed) ?? key,
                                   "\(bool ? 1 : 0)"))
            default:
                components.append((key.addingPercentEncoding(withAllowedCharacters: .apiURLQueryAllowed) ?? key,
                                   "\(value)".addingPercentEncoding(withAllowedCharacters: .apiURLQueryAllowed)
                                    ?? "\(value)"))
            }
        }

        return components
    }

    static func queryComponents(fromKey key: String, value: Any) -> [(String, String)] {
            var components: [(String, String)] = []
            switch value {
            case let dictionary as [String: Any]:
                for (nestedKey, value) in dictionary {
                    components += queryComponents(fromKey: "\(key)[\(nestedKey)]", value: value)
                }
            case let array as [Any]:
                for value in array {
                    components += queryComponents(fromKey: "\(key)[]", value: value)
                }
            case let number as NSNumber:
                components.append((key.addingPercentEncoding(withAllowedCharacters: .apiURLQueryAllowed) ?? key,
                                   "\(number)".addingPercentEncoding(withAllowedCharacters: .apiURLQueryAllowed)
                                    ?? "\(number)"))
            case let bool as Bool:
                components.append((key.addingPercentEncoding(withAllowedCharacters: .apiURLQueryAllowed) ?? key,
                                   "\(bool ? 1 : 0)"))
            default:
                components.append((key.addingPercentEncoding(withAllowedCharacters: .apiURLQueryAllowed) ?? key,
                                   "\(value)".addingPercentEncoding(withAllowedCharacters: .apiURLQueryAllowed)
                                    ?? "\(value)"))
            }
            return components
        }
}
