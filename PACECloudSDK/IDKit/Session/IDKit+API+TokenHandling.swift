//
//  IDKit+API+TokenHandling.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

extension IDKit {
    func performApiInducedRefresh(_ completion: @escaping (Bool) -> Void) {
        performRefresh { accessToken, error in
            completion(error == nil && accessToken != nil)
        }
    }
}
