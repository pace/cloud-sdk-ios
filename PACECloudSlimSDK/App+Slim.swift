//
//  App+Slim.swift
//  PACECloudSlimSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

// MARK: - 2FA
// Default implementation does nothing
extension App {
    func handleBiometryAvailbilityRequest(query: String, host: String) {}
    func setTOTPSecret(query: String, host: String) {}
    func getTOTP(query: String, host: String) {}
    func setSecureData(query: String, host: String) {}
    func getSecureData(query: String, host: String) {}
}
