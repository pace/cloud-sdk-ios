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
    func handleBiometryAvailabilityRequest(with request: AppKit.AppRequestData<String?>) {}
    func setTOTPSecret(with request: AppKit.AppRequestData<AppKit.TOTPSecretData>, requestUrl: URL?) {}
    func getTOTP(with request: AppKit.AppRequestData<AppKit.GetTOTPData>, requestUrl: URL?) {}
    func setSecureData(with request: AppKit.AppRequestData<AppKit.SetSecureData>, requestUrl: URL?) {}
    func getSecureData(with request: AppKit.AppRequestData<AppKit.GetSecureData>, requestUrl: URL?) {}
}
