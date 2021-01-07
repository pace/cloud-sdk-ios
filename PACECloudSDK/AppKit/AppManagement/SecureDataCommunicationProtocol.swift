//
//  SecureDataCommunicationProtocol.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

protocol SecureDataCommunication {
    func handleBiometryAvailbilityRequest(query: String, host: String)
    func setTOTPSecret(query: String, host: String)
    func getTOTP(query: String, host: String)
    func setSecureData(query: String, host: String)
    func getSecureData(query: String, host: String)
}
