//
//  AppKit+Delegate+Logout.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

public extension AppKitDelegate {
    func logout(completion: @escaping ((AppKit.LogoutResponse) -> Void)) {
        IDKit.resetSession {
            completion(AppKit.LogoutResponse(statusCode: "\(HttpStatusCode.okNoContent)"))
        }
    }
}
