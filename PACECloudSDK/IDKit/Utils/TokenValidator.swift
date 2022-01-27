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

        /**
         Returns the payload value of the given token associated with the specified key.

         - parameter key: The key the payload value should be retrieved for.
         - parameter token: The access token the payload value should be retrieved of.
         - returns: The payload value if available. `Nil` otherwise.
         */
        public static func jwtValue(for key: String, of token: String) -> Any? {
            do {
                let jwtToken = try JWTToken.decode(jwt: token)
                return jwtToken.payload?[key]
            } catch {
                IDKitLogger.e("[TokenValidator] Failed to decode token \(token) - Error: \(error)")
                return nil
            }
        }

        /**
         Returns a set of payment method kinds that are currently allowed to be onboarded for the passed `token`.
         - parameter token: The access token the payment method kinds should be retrieved for.
         - returns: `nil` if no payment method kinds are available.
         If all of the payment methods kinds are allowed to be onboarded, an empty set will be returned, otherwise only the ones allowed.
         */
        public static func paymentMethodKinds(for token: String) -> Set<String>? {
            guard let scope = jwtValue(for: "scope", of: token) as? String else {
                return nil
            }

            let scopes = scope.components(separatedBy: " ")
            let paymentMethodScope = "pay:payment-methods:create"
            let individualScopePrefix = "\(paymentMethodScope):"

            let generalScope = scopes.first(where: { $0 == paymentMethodScope })
            let individualScopes = scopes.filter { $0.hasPrefix(individualScopePrefix) }

            if generalScope != nil {
                return .init()
            } else if !individualScopes.isEmpty {
                return individualScopes.reduce(into: Set<String>()) { result, scope in
                    let paymentMethodKind = String(scope.dropFirst(individualScopePrefix.count))
                    result.insert(paymentMethodKind)
                }
            } else {
                return nil
            }
        }
    }
}
