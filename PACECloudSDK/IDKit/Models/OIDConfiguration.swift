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
        let redirectUrl: String
        let responseType: String
        let additionalParameters: [String: String]?

        public init(authorizationEndpoint: String,
                    tokenEndpoint: String,
                    userEndpoint: String? = nil,
                    clientId: String,
                    clientSecret: String? = nil,
                    scopes: [String]? = nil,
                    redirectUrl: String,
                    responseType: String = OIDResponseTypeCode,
                    additionalParameters: [String: String]? = nil) {
            self.authorizationEndpoint = authorizationEndpoint
            self.tokenEndpoint = tokenEndpoint
            self.userEndpoint = userEndpoint
            self.clientId = clientId
            self.clientSecret = clientSecret
            self.scopes = scopes
            self.redirectUrl = redirectUrl
            self.responseType = responseType
            self.additionalParameters = additionalParameters
        }
    }
}
