//
//  SecureDataCommunicationProtocol.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation
import WebKit

protocol SecureDataCommunication {
    func handleBiometryAvailbilityRequest()
    func setTOTPSecret(with message: WKScriptMessage)
    func getTOTP(with message: WKScriptMessage)
    func setSecureData(with message: WKScriptMessage)
    func getSecureData(with message: WKScriptMessage)
}
