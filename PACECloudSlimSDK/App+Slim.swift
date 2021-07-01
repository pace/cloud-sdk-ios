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
    func handleBiometryAvailabilityRequest(with request: AppKit.EmptyRequestData) {}
    func setTOTPSecret(with request: AppKit.AppRequestData<AppKit.TOTPSecretData>, requestUrl: URL?, completion: @escaping () -> Void) {}
    func getTOTP(with request: AppKit.AppRequestData<AppKit.GetTOTPData>, requestUrl: URL?, completion: @escaping () -> Void) {}
    func setSecureData(with request: AppKit.AppRequestData<AppKit.SetSecureData>, requestUrl: URL?) {}
    func getSecureData(with request: AppKit.AppRequestData<AppKit.GetSecureData>, requestUrl: URL?, completion: @escaping () -> Void) {}
}

// MARK: - Access token
extension App {
    func handleGetAccessToken(with request: API.Communication.GetAccessTokenRequest, completion: @escaping (API.Communication.GetAccessTokenResult) -> Void) {}
}
