//
//  IDKit+OIDConfiguration.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import AppAuth

extension IDKit {
    static func performDiscovery(issuerUrl: String, _ completion: @escaping (Result<OIDConfiguration.Response, IDKitError>) -> Void) {
        guard let issuer = URL(string: issuerUrl) else {
            completion(.failure(.invalidIssuerUrl))
            return
        }

        OIDAuthorizationService.discoverConfiguration(forIssuer: issuer) { configuration, error in
            if let error = error {
                completion(.failure(.other(error)))
                return
            }

            guard let configuration = configuration else {
                completion(.failure(.failedRetrievingConfigurationWhileDiscovering))
                return
            }

            let authorizationEndpoint = configuration.authorizationEndpoint.absoluteString
            let tokenEndpoint = configuration.tokenEndpoint.absoluteString

            completion(.success(.init(authorizationEndpoint: authorizationEndpoint,
                                      tokenEndpoint: tokenEndpoint)))

            IDKitLogger.i("Discovery successful")
        }
    }
}

// MARK: - Concurrency

@available(iOS 13.0, watchOS 6.0, *) @MainActor
extension IDKit {
    static func performDiscovery(issuerUrl: String) async -> Result<OIDConfiguration.Response, IDKitError> {
        await withCheckedContinuation { continuation in
            performDiscovery(issuerUrl: issuerUrl) { result in
                continuation.resume(returning: result)
            }
        }
    }
}
