//
//  SecureDataCommunicationProtocol.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation
import WebKit

protocol SecureDataCommunication {
    func handleBiometryAvailabilityRequest(with request: AppKit.EmptyRequestData)
    func setTOTPSecret(with request: AppKit.AppRequestData<AppKit.TOTPSecretData>, requestUrl: URL?, completion: @escaping () -> Void)
    func getTOTP(with request: AppKit.AppRequestData<AppKit.GetTOTPData>, requestUrl: URL?, completion: @escaping () -> Void)
    func setSecureData(with request: AppKit.AppRequestData<AppKit.SetSecureData>, requestUrl: URL?)
    func getSecureData(with request: AppKit.AppRequestData<AppKit.GetSecureData>, requestUrl: URL?, completion: @escaping () -> Void)
}
