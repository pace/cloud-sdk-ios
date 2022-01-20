//
//  IDKit+API+TokenHandling.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

extension IDKit {
    func performApiInducedRefresh(_ completion: @escaping (Bool) -> Void) {
        performRefresh { result in
            switch result {
            case .success(let accessToken):
                completion(accessToken != nil)

            case .failure:
                completion(false)
            }
        }
    }
}
