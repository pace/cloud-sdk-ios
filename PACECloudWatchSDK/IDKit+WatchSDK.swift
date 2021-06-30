//
//  IDKit+WatchSDK.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation


public class IDKit {
    public struct OIDConfiguration {}

    static var isSessionAvailable: Bool {
        false
    }

    static func apiInducedRefresh(_ completion: @escaping (Bool) -> Void) {
        completion(false)
    }
}
