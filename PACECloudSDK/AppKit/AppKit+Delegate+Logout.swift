//
//  AppKit+Delegate+Logout.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

public extension AppKitDelegate {
    func logout(completion: @escaping ((AppKit.LogoutResponse) -> Void)) {
        IDKit.resetSession { result in
            switch result {
            case .success:
                completion(AppKit.LogoutResponse(statusCode: .okNoContent))

            case .failure(let error):
                Logger.w(error.description)
                completion(AppKit.LogoutResponse(statusCode: .internalError))
            }
        }
    }
}
