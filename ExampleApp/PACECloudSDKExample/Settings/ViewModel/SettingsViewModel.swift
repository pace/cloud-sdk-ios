//
//  SettingsViewModel.swift
//  PACECloudSDKExample
//
//  Created by PACE Telematics GmbH.
//

import Foundation
import SwiftUI

protocol SettingsViewModel: ObservableObject {
    var isBiometricAuthenticationEnabled: Bool { get }
    var userEmail: String { get }

    func enableBiometricAuthentication(password: String?,
                                       pin: String?,
                                       otp: String?,
                                       completion: @escaping (Bool?) -> Void)
    func disableBiometricAuthentication()
    func isPasswordSet(completion: @escaping (Bool?) -> Void)
    func isPINSet(completion: @escaping (Bool?) -> Void)
    func setPIN(pin: String, password: String?, otp: String?, completion: @escaping (Bool) -> Void)
    func sendMailOTP(completion: @escaping (Bool?) -> Void)
    func logout()
    func isPoiInRange(with id: String, completion: @escaping (Bool) -> Void)
}
