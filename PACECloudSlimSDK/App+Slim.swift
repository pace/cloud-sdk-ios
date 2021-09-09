//
//  App+Slim.swift
//  PACECloudSlimSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation
import WebKit

// MARK: - 2FA
// Default implementation does nothing
extension App {
    func handleGetBiometricStatus(completion: @escaping (API.Communication.GetBiometricStatusResult) -> Void) {}
    func handleSetTOTP(with request: API.Communication.SetTOTPRequest, requestUrl: URL?, completion: @escaping (API.Communication.SetTOTPResult) -> Void) {}
    func handleGetTOTP(with request: API.Communication.GetTOTPRequest, requestUrl: URL?, completion: @escaping (API.Communication.GetTOTPResult) -> Void) {}
    func handleSetSecureData(with request: API.Communication.SetSecureDataRequest, requestUrl: URL?, completion: @escaping (API.Communication.SetSecureDataResult) -> Void) {}
    func handleGetSecureData(with request: API.Communication.GetSecureDataRequest, requestUrl: URL?, completion: @escaping (API.Communication.GetSecureDataResult) -> Void) {}
    func handleIsBiometricAuthEnabled(completion: @escaping (API.Communication.IsBiometricAuthEnabledResult) -> Void) {}
    func handleIsSignedIn(completion: @escaping (API.Communication.IsSignedInResult) -> Void) {}
}

// MARK: - Access token
extension App {
    func handleGetAccessToken(with request: API.Communication.GetAccessTokenRequest, completion: @escaping (API.Communication.GetAccessTokenResult) -> Void) {}
}
