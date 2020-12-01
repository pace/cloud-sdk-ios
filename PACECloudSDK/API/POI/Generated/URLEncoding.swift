//
//  URLEncoding.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

struct URLEncoding {
    static func encodeParams(_ params: [String: Any]) -> String {
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

        return components.map { "\($0)=\($1)" }.joined(separator: "&")
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
