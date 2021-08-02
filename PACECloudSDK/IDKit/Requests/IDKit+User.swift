//
//  IDKit+User.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

extension IDKit {
    func userInfo(completion: @escaping (Result<UserInfo, IDKitError>) -> Void) {
        guard let userEndpointUrlString = configuration.userEndpoint,
              let userEndpointUrl = URL(string: userEndpointUrlString) else {
            completion(.failure(.invalidAuthorizationEndpoint))
            return
        }

        performHTTPRequest(for: userEndpointUrl, type: UserInfo.self) { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
}
