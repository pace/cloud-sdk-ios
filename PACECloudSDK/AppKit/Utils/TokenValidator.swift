//
//  TokenValidator.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

public extension AppKit {
    struct TokenValidator {
        public static func isTokenValid(_ token: String) -> Bool {
            let jwtToken: JWTToken

            do {
                jwtToken = try JWTToken.decode(jwt: token)
            } catch {
                AppKitLogger.e("[TokenValidator] Failed to decode token \(token) - Error: \(error)")
                return false
            }

            guard let expirationDate = jwtToken.expiresAt,
                  let now = Calendar.current.date(byAdding: .minute, value: -10, to: Date())
            else {
                AppKitLogger.e("[TokenValidator] Failed to extract expiration date of token \(token)")
                return false
            }

            return expirationDate > now
        }
    }
}
