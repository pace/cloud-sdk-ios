//
//  IDKit+API+TokenHandling.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

extension IDKit {
    func performApiInducedRefresh(_ completion: @escaping (IDKitError?) -> Void) {
        performRefresh { result in
            switch result {
            case .success(let accessToken):
                if accessToken == nil {
                    completion(.invalidSession)
                } else {
                    completion(nil)
                }

            case .failure(let error):
                completion(error)
            }
        }
    }
}
