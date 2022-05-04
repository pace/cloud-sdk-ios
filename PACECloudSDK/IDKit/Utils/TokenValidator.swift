//
//  TokenValidator.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

public extension IDKit {
    class TokenValidator {
        private let dateTimeProvider: DateTimeProvider
        private var jwtToken: JWTToken?

        public var accessToken: String {
            didSet {
                decodeAccessToken()
            }
        }

        init(accessToken: String, dateTimeProvider: DateTimeProvider) {
            self.accessToken = accessToken
            self.dateTimeProvider = dateTimeProvider
            decodeAccessToken()
        }

        private func decodeAccessToken() {
            do {
                jwtToken = try JWTToken.decode(jwt: accessToken)
            } catch {
                jwtToken = nil
                IDKitLogger.e("[TokenValidator] Failed to decode token \(accessToken) - Error: \(error)")
            }
        }
    }
}

public extension IDKit.TokenValidator {
    convenience init(accessToken: String) {
        self.init(accessToken: accessToken, dateTimeProvider: DateTimeProviderHelper())
    }

    /**
     Checks if the specified access token is still valid regarding its expiry date.

     - parameter token: The access token to be checked.
     - parameter minutes: The number of minutes the token is supposed to be valid for. Defaults to `10`.
     - returns: `True` if the token's expiration date lies more than the specified number of minutes ahead. `False` otherwise.
     */
    func isTokenValid(for minutes: Int = 10) -> Bool {
        guard let jwtToken = jwtToken,
              let expirationDate = jwtToken.expiresAt,
              let validUntilDate = Calendar.current.date(byAdding: .minute, value: minutes, to: dateTimeProvider.currentDate)
        else {
            IDKitLogger.e("[TokenValidator] Failed to extract expiration date of token \(accessToken)")
            return false
        }

        return expirationDate > validUntilDate
    }

    /**
     Returns the payload value of the given token associated with the specified key.

     - parameter key: The key the payload value should be retrieved for.
     - parameter token: The access token the payload value should be retrieved of.
     - returns: The payload value if available. `Nil` otherwise.
     */
    func jwtValue(for key: String) -> Any? {
        jwtToken?.payload?[key]
    }
}
