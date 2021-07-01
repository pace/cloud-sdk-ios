//
//  SecureDataCommunicationProtocol.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation
import WebKit

protocol SecureDataCommunication {
    func handleGetBiometricStatus(completion: @escaping (API.Communication.GetBiometricStatusResult) -> Void)
    func handleSetTOTP(
        with request: API.Communication.SetTOTPRequest,
        requestUrl: URL?,
        completion: @escaping (API.Communication.SetTOTPResult) -> Void
    )
    func handleGetTOTP(
        with request: API.Communication.GetTOTPRequest,
        requestUrl: URL?,
        completion: @escaping (API.Communication.GetTOTPResult) -> Void
    )
    func handleSetSecureData(
        with request: API.Communication.SetSecureDataRequest,
        requestUrl: URL?,
        completion: @escaping (API.Communication.SetSecureDataResult) -> Void
    )
    func handleGetSecureData(
        with request: API.Communication.GetSecureDataRequest,
        requestUrl: URL?,
        completion: @escaping (API.Communication.GetSecureDataResult) -> Void
    )
}
