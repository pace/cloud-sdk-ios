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
        let endSessionEndpoint: String?

        let clientId: String
        let clientSecret: String?
        let scopes: [String]?
        let redirectUri: String
        let responseType: String
        var additionalParameters: [String: String]?

        /// Creates an instance of `OIDConfiguration` with the specified values
        public init(authorizationEndpoint: String,
                    tokenEndpoint: String,
                    userEndpoint: String? = nil,
                    endSessionEndpoint: String? = nil,
                    clientId: String,
                    clientSecret: String? = nil,
                    scopes: [String]? = nil,
                    redirectUri: String,
                    responseType: String = OIDResponseTypeCode,
                    additionalParameters: [String: String]? = nil) {
            self.authorizationEndpoint = authorizationEndpoint
            self.tokenEndpoint = tokenEndpoint
            self.userEndpoint = userEndpoint
            self.endSessionEndpoint = endSessionEndpoint
            self.clientId = clientId
            self.clientSecret = clientSecret
            self.scopes = scopes
            self.redirectUri = redirectUri
            self.responseType = responseType
            self.additionalParameters = additionalParameters
        }

        /**
         Appends additional parameters to the existing OID configuration.

         Make sure the PACECloudSDK has already been set up via `PACECloudSDK.shared.setup()`
         before calling this method.

         - parameter parameters: The additional parameters.
         */
        public static func appendAdditionalParameters(_ parameters: [String: String]) {
            let currentParams = shared?.configuration.additionalParameters ?? [:]

            // Append parameters to existing ones by
            // choosing theses keys over the current ones if duplicates occur
            shared?.configuration.additionalParameters = currentParams.merging(parameters, uniquingKeysWith: { $1 })
        }

        /**
         Creates a default OID Configuration with all endpoints pointing to PACE ID.
         - parameter clientId: The client id of the OID configuration.
         - parameter redirectUri: The redirect uri of the OID configuration.
         - parameter idpHint: The IDP hint of the OID configuration. Defaults to `nil`.
         */
        public static func defaultOIDConfiguration(clientId: String, redirectUri: String, idpHint: String? = nil) -> OIDConfiguration {
            var additionalParameters: [String: String]?

            if let idpHint = idpHint {
                additionalParameters = [IDKitConstants.kcIdpHint: idpHint]
            }

            return .init(authorizationEndpoint: Settings.shared.authorizationEndpointUrl,
                         tokenEndpoint: Settings.shared.tokenEndpointUrl,
                         userEndpoint: Settings.shared.userEndpointUrl,
                         endSessionEndpoint: Settings.shared.endSessionEndpointUrl,
                         clientId: clientId,
                         redirectUri: redirectUri,
                         additionalParameters: additionalParameters)
        }
    }
}

public extension IDKit.OIDConfiguration {
    struct Response {
        let authorizationEndpoint: String
        let tokenEndpoint: String
    }
}
