//
//  IDKit+Slim.swift
//  PACECloudSlimSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

public struct IDKit {
    public struct OIDConfiguration {}

    static var isSessionAvailable: Bool {
        false
    }

    static func determineOIDConfiguration(with customOIDConfig: OIDConfiguration? = nil) {}
    static func apiInducedRefresh(_ completion: @escaping (Bool) -> Void) {
        completion(false)
    }
}
