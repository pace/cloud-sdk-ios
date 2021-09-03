//
//  TokenValidator.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

public extension IDKit {
    struct TokenValidator {

        /**
         Checks if the specified access token is still valid regarding its expiry date.

         - parameter token: The access token to be checked.
         - parameter minutes: The number of minutes the token is supposed to be valid for. Defaults to `10`.
         - returns: `True` if the token's expiration date lies more than the specified number of minutes ahead. `False` otherwise.
         */
        public static func isTokenValid(_ token: String, for minutes: Int = 10) -> Bool {
            let jwtToken: JWTToken

            do {
                jwtToken = try JWTToken.decode(jwt: token)
            } catch {
                IDKitLogger.e("[TokenValidator] Failed to decode token \(token) - Error: \(error)")
                return false
            }

            guard let expirationDate = jwtToken.expiresAt,
                  let now = Calendar.current.date(byAdding: .minute, value: -minutes, to: Date())
            else {
                IDKitLogger.e("[TokenValidator] Failed to extract expiration date of token \(token)")
                return false
            }

            return expirationDate > now
        }
    }
}
