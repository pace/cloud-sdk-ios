//
//  IDKitDelegate.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

public protocol IDKitDelegate: AnyObject {
    /**
     Will be invoked right before the session is about to be reset.

     Implement this method to handle an incoming session reset. The default implementation does nothing.

     - parameter error: The error that caused the session renewal to fail if available.
     */
    func willResetSession()

    /**
     Will be invoked if an automatic session renewal triggered by the SDK itself has failed and the session has been reset.

     Implement this method to specify a custom behaviour for the token retrieval.
     If not implemented an authorization will be performed automatically which will result in showing a sign in mask for the user.

     - parameter error: The error that caused the session renewal to fail if available.
     - parameter completion: The block to be called to pass the new access token if available.
     */
    func didFailSessionRenewal(with error: IDKit.IDKitError?, _ completion: @escaping (String?) -> Void)

    /**
     Will be invoked after the SDK performed an automatic authorization.

     Implement this method to be able to react to automatic authorizations by the SDK.

     - parameter result:The result of the authorization containing either the access token if successful or an error.
     */
    func didPerformAuthorization(_ result: Result<String, IDKit.IDKitError>)
}

public extension IDKitDelegate {
    func willResetSession() {}

    func didFailSessionRenewal(with error: IDKit.IDKitError?, _ completion: @escaping (String?) -> Void) {
        IDKit.appInducedAuthorization(completion)
    }

    func didPerformAuthorization(_ result: Result<String, IDKit.IDKitError>) {}
}
