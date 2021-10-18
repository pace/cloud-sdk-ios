//
//  JWTToken.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

struct JWTToken {
    enum JWTError: Error, CustomStringConvertible {
        case invalidPartCount
        case invalidBase64Url
        case invalidJSON

        var description: String {
            switch self {
            case .invalidPartCount:
                return "JWT Error - invalid part count"

            case .invalidBase64Url:
                return "JWT Error - invalid base64 url"

            case .invalidJSON:
                return "JWT Error - invalid json"
            }
        }
    }

    var payload: [String: Any]?

    var expiresAt: Date?

    init(jwt: String) throws {
        let parts = jwt.components(separatedBy: ".")

        // Header, body, signature
        guard parts.count == 3 else {
            throw JWTError.invalidPartCount
        }

        let payload = try decodeBody(parts[1])
        self.payload = payload

        expiresAt = date(from: payload["exp"])
    }

    private func decodeBody(_ body: String) throws -> [String: Any] {
        guard let bodyData = decodeBase64Url(body) else {
            throw JWTError.invalidBase64Url
        }

        guard let object = try? JSONSerialization.jsonObject(with: bodyData, options: []), let json = object as? [String: Any] else {
            throw JWTError.invalidJSON
        }

        return json
    }

    private func decodeBase64Url(_ url: String) -> Data? {
        var base64 = url.replacingOccurrences(of: "-", with: "+").replacingOccurrences(of: "_", with: "/")

        let length = Double(base64.lengthOfBytes(using: String.Encoding.utf8))
        let requiredLength = 4 * ceil(length / 4.0)
        let paddingLength = requiredLength - length

        if paddingLength > 0 {
            let padding = "".padding(toLength: Int(paddingLength), withPad: "=", startingAt: 0)
            base64 += padding
        }

        return Data(base64Encoded: base64, options: .ignoreUnknownCharacters)
    }

    static func decode(jwt: String) throws -> JWTToken {
        try JWTToken(jwt: jwt)
    }
}

private extension JWTToken {
    func date(from value: Any?) -> Date? {
        guard let timestamp: TimeInterval = double(from: value) else { return nil }
        return Date(timeIntervalSince1970: timestamp)
    }

    func double(from value: Any?) -> Double? {
        let double: Double?

        if let string = value as? String {
            double = Double(string)
        } else {
            double = value as? Double
        }
        return double
    }
}
