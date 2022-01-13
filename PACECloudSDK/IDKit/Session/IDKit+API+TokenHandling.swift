//
//  IDKit+API+TokenHandling.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

extension IDKit {
    func performApiInducedRefresh(_ completion: @escaping (Bool) -> Void) {
        performRefresh { [weak self] result in
            switch result {
            case .success(let accessToken):
                completion(accessToken != nil)

            case .failure(let error):
                guard case .invalidSession = error else {
                    completion(false)
                    return
                }

                self?.performSDKInducedSessionReset(with: error) { accessToken in
                    completion(accessToken != nil)
                }
            }
        }
    }
}
