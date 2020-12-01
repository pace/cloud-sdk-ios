//
//  IDKit+User.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

extension IDKit {
    func userInfo(completion: @escaping (UserInfo?, IDKitError?) -> Void) {
        guard let userEndpointUrlString = configuration.userEndpoint,
              let userEndpointUrl = URL(string: userEndpointUrlString) else {
            completion(nil, IDKitError.invalidAuthorizationEndpoint)
            return
        }

        performHTTPRequest(for: userEndpointUrl, type: UserInfo.self) { userInfo, error in
            DispatchQueue.main.async {
                completion(userInfo, error)
            }
        }
    }
}
