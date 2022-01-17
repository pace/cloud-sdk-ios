//
//  IDKit+App+TokenHandling.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import AppAuth
import Foundation

extension IDKit {
    func performAppInducedRefresh(_ completion: @escaping (String?) -> Void) {
        guard IDKit.isSessionAvailable else {
            performSDKInducedAuthorization(completion)
            return
        }

        performRefresh { [weak self] result in
            switch result {
            case .success(let accessToken):
                completion(accessToken)

            case .failure(let error):
                guard case .invalidSession = error else {
                    completion(nil)
                    return
                }

                self?.performSDKInducedSessionReset(with: error, completion)
            }
        }
    }
}
