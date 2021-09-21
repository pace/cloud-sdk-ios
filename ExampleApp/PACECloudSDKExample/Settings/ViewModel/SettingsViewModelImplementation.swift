//
//  SettingsViewModelImplementation.swift
//  PACECloudSDKExample
//
//  Created by PACE Telematics GmbH.
//

import Foundation
import PACECloudSDK
import SwiftUI

class SettingsViewModelImplementation: SettingsViewModel {
    var isBiometricAuthenticationEnabled: Bool {
        IDControl.shared.isBiometricAuthenticationEnabled()
    }

    @Published var userEmail: String = ""

    init() {
        fetchUserEmail()
    }

    private func fetchUserEmail() {
        IDKit.userInfo { [weak self] result in
            switch result {
            case .success(let userInfo):
                self?.userEmail = userInfo.email ?? "Could not retrieve user info"

            case .failure(let error):
                ExampleLogger.e("Failed fetching user info with error \(error)")
                self?.userEmail = "Could not retrieve user info"
            }
        }
    }

    func enableBiometricAuthentication(password: String?,
                                       pin: String?,
                                       otp: String?,
                                       completion: @escaping (Bool?) -> Void) {
        if let password = password {
            IDControl.shared.enableBiometricAuthentication(password: password, completion: completion)
        } else if let pin = pin {
            IDControl.shared.enableBiometricAuthentication(pin: pin, completion: completion)
        } else if let otp = otp {
            IDControl.shared.enableBiometricAuthentication(otp: otp, completion: completion)
        } else {
            completion(false)
        }
    }

    func disableBiometricAuthentication() {
        IDControl.shared.disableBiometricAuthentication()
    }

    func isPasswordSet(completion: @escaping (Bool?) -> Void) {
        IDControl.shared.isPasswordSet(completion: completion)
    }

    func isPINSet(completion: @escaping (Bool?) -> Void) {
        IDControl.shared.isPINSet(completion: completion)
    }

    func setPIN(pin: String, password: String?, otp: String?, completion: @escaping (Bool) -> Void) {
        if let password = password {
            IDControl.shared.setPIN(pin: pin, password: password, completion: completion)
        } else if let otp = otp {
            IDControl.shared.setPIN(pin: pin, otp: otp, completion: completion)
        } else {
            completion(false)
        }
    }

    func sendMailOTP(completion: @escaping (Bool?) -> Void) {
        IDControl.shared.sendMailOTP(completion: completion)
    }

    func logout() {
        IDControl.shared.reset()
    }

    func isPoiInRange(with id: String, completion: @escaping (Bool) -> Void) {
        AppControl.shared.isPoiInRange(with: id, completion: completion)
    }
}
