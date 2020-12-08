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
    func handleBiometryAvailbilityRequest() {}
    func setTOTPSecret(with message: WKScriptMessage) {}
    func getTOTP(with message: WKScriptMessage) {}
    func setSecureData(with message: WKScriptMessage) {}
    func getSecureData(with message: WKScriptMessage) {}
}
