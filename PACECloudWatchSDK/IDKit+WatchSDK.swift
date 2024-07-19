//
//  IDKit+WatchSDK.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

public class IDKit {
    public struct OIDConfiguration {}
    static var isSessionAvailable: Bool { false }
    static func refreshToken(force: Bool = false, _ completion: @escaping (Result<String?, IDKitError>) -> Void) { completion(.failure(.invalidSession)) }
    static func handleAdditionalQueryParams(_ params: Set<URLQueryItem>) { }
    static func latestAccessToken() -> String? { nil }
}
