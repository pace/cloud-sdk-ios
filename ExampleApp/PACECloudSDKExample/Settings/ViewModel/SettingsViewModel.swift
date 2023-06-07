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
                                       otp: String?) async -> Bool?
    func disableBiometricAuthentication()
    func isPasswordSet() async -> Bool?
    func isPINSet() async -> Bool?
    func setPIN(pin: String, password: String?, otp: String?) async -> Bool
    func sendMailOTP() async -> Bool?
    func fetchIconsViaPaymentMethodKinds(completion: @escaping (Bool) -> Void)
    func fetchIconsViaPaymentMethodVendors(completion: @escaping (Bool) -> Void)
    func logout()
    func isPoiInRange(with id: String, completion: @escaping (Bool) -> Void)
}
