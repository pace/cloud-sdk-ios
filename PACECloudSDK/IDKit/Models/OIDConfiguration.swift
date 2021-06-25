//
//  OIDConfiguration.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import AppAuth
import Foundation

public extension IDKit {
    struct OIDConfiguration {
        let authorizationEndpoint: String
        let tokenEndpoint: String
        let userEndpoint: String?

        let clientId: String
        let clientSecret: String?
        let scopes: [String]?
        let redirectUri: String
        let responseType: String
        var additionalParameters: [String: String]?

        public init(authorizationEndpoint: String,
                    tokenEndpoint: String,
                    userEndpoint: String? = nil,
                    clientId: String,
                    clientSecret: String? = nil,
                    scopes: [String]? = nil,
                    redirectUri: String,
                    responseType: String = OIDResponseTypeCode,
                    additionalParameters: [String: String]? = nil) {
            self.authorizationEndpoint = authorizationEndpoint
            self.tokenEndpoint = tokenEndpoint
            self.userEndpoint = userEndpoint
            self.clientId = clientId
            self.clientSecret = clientSecret
            self.scopes = scopes
            self.redirectUri = redirectUri
            self.responseType = responseType
            self.additionalParameters = additionalParameters
        }

        public static func appendAdditionalParameters(_ parameters: [String: String]) {
            let currentParams = shared?.configuration.additionalParameters ?? [:]

            // Append parameters to existing ones by
            // choosing theses keys over the current ones if duplicates occur
            shared?.configuration.additionalParameters = (shared?.configuration.additionalParameters ?? [:]).merging(parameters, uniquingKeysWith: { $1 })
        }

        static func defaultOIDConfiguration(clientId: String, redirectUri: String, idpHint: String?) -> OIDConfiguration {
            var additionalParameters: [String: String]?

            if let idpHint = idpHint {
                additionalParameters = [IDKitConstants.kcIdpHint: idpHint]
            }

            return .init(authorizationEndpoint: Settings.shared.authorizationEndpointUrl,
                         tokenEndpoint: Settings.shared.tokenEndpointUrl,
                         userEndpoint: Settings.shared.userEndpointUrl,
                         clientId: clientId,
                         redirectUri: redirectUri,
                         additionalParameters: additionalParameters)
        }
    }
}
