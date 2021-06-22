//
//  IDKitDelegate.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

public protocol IDKitDelegate: AnyObject {
    /**
     Will be invoked if an automatic session renewal triggered by the SDK itself fails.

     Implement this method to specify a custom behaviour for the token retrieval.
     If not implemented an authorization will be performed automatically which will result in showing a sign in mask for the user.

     - parameter error: The error that caused the session renewal to fail if available.
     - parameter completion: The block to be called to pass the new access token if available.
     */
    func didFailSessionRenewal(with error: IDKit.IDKitError?, _ completion: @escaping (String?) -> Void)
}

public extension IDKitDelegate {
    func didFailSessionRenewal(with error: IDKit.IDKitError?, _ completion: @escaping (String?) -> Void) {
        IDKit.appInducedAuthorization(completion)
    }
}
