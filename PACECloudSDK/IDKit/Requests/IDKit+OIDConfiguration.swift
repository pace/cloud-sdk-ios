//
//  IDKit+OIDConfiguration.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import AppAuth

extension IDKit {
    static func performDiscovery(issuerUrl: String, _ completion: @escaping ((String?, String?, IDKitError?) -> Void)) {
        guard let issuer = URL(string: issuerUrl) else {
            completion(nil, nil, IDKitError.invalidIssuerUrl)
            return
        }

        OIDAuthorizationService.discoverConfiguration(forIssuer: issuer) { configuration, error in
            if let error = error {
                completion(nil, nil, IDKitError.other(error))
                return
            }

            guard let configuration = configuration else {
                completion(nil, nil, IDKitError.failedRetrievingConfigurationWhileDiscovering)
                return
            }

            let authorizationEndpoint = configuration.authorizationEndpoint.absoluteString
            let tokenEndpoint = configuration.tokenEndpoint.absoluteString

            completion(authorizationEndpoint, tokenEndpoint, nil)

            IDKitLogger.i("Discovery successful")
        }
    }
}
