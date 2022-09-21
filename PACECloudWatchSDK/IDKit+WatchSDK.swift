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

    static func apiInducedRefresh(_ completion: @escaping (IDKitError?) -> Void) {
        completion(nil)
    }

    static func handleAdditionalQueryParams(_ params: Set<URLQueryItem>) { }

    static func latestAccessToken() -> String? { nil }
}
