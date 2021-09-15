//
//  IDControl.swift
//  PACECloudSDKExample
//
//  Created by PACE Telematics GmbH.
//

import Foundation
import PACECloudSDK
import UIKit

class IDControl: ObservableObject {
    static var shared = IDControl()

    @Published private(set) var isSessionValid: Bool = false
    @Published private(set) var isRefreshing: Bool = false

    private init() {}

    func reset() {
        IDKit.resetSession { [weak self] in
            self?.updateSessionInformation()
        }
    }

    func isAuthorizationValid() -> Bool {
        IDKit.isAuthorizationValid()
    }

    func updateSessionInformation() {
        isSessionValid = IDKit.isAuthorizationValid()
    }

    func authorize(with viewController: UIViewController) {
        IDKit.presentingViewController = viewController
        IDKit.authorize { [weak self] result in
            switch result {
            case .success(let accessToken):
                guard let token = accessToken, !token.isEmpty else {
                    NSLog("Token invalid")
                    return
                }
                self?.userInfo()

            case .failure(let error):
                NSLog("Failed authorizing with error \(error)")
            }
            self?.updateSessionInformation()
        }
    }

    func refresh() {
        isRefreshing = true
        IDKit.refreshToken { [weak self] result in
            defer {
                DispatchQueue.main.async { [weak self] in
                    self?.isRefreshing = false
                }
            }

            switch result {
            case .success(let accessToken):
                guard let token = accessToken, !token.isEmpty else {
                    NSLog("Token invalid")
                    return
                }

            case .failure(let error):
                NSLog("Failed refreshing with error \(error)")
            }

            self?.updateSessionInformation()
        }
    }

    func userInfo() {
        IDKit.userInfo { result in
            switch result {
            case .success(let userInfo):
                NSLog("Did reveice user info \(userInfo)")

            case .failure(let error):
                NSLog("UserInfo error \(error)")
            }
        }
    }

    func isPINSet(completion: @escaping (Bool?) -> Void) {
        IDKit.isPINSet { result in
            switch result {
            case .success(let isSet):
                completion(isSet)
                NSLog("Is pin set: \(isSet)")

            case .failure(let error):
                completion(nil)
                NSLog("IsPINSet failed with error \(error)")
            }
        }
    }

    func isPasswordSet(completion: @escaping (Bool?) -> Void) {
        IDKit.isPasswordSet { result in
            switch result {
            case .success(let isSet):
                completion(isSet)
                NSLog("Is password set: \(isSet)")

            case .failure(let error):
                completion(nil)
                NSLog("IsPasswordSet failed with error \(error)")
            }
        }
    }

    func isBiometricAuthenticationEnabled() -> Bool {
        IDKit.isBiometricAuthenticationEnabled()
    }

    func enableBiometricAuthentication(password: String, completion: @escaping (Bool) -> Void) {
        IDKit.enableBiometricAuthentication(password: password) { result in
            switch result {
            case .success(let successful):
                completion(successful)
                NSLog("Enabling biometry with password successful: \(successful)")

            case .failure(let error):
                completion(false)
                NSLog("Enabling biometry with password failed with error \(error)")
            }
        }
    }

    func enableBiometricAuthentication(pin: String, completion: @escaping (Bool) -> Void) {
        IDKit.enableBiometricAuthentication(pin: pin) { result in
            switch result {
            case .success(let successful):
                completion(successful)
                NSLog("Enabling biometry with pin successful: \(successful)")

            case .failure(let error):
                completion(false)
                NSLog("Enabling biometry with pin failed with error \(error)")
            }
        }
    }

    func enableBiometricAuthentication(otp: String, completion: @escaping (Bool) -> Void) {
        IDKit.enableBiometricAuthentication(otp: otp) { result in
            switch result {
            case .success(let successful):
                completion(successful)
                NSLog("Enabling biometry with otp successful: \(successful)")

            case .failure(let error):
                completion(false)
                NSLog("Enabling biometry with otp failed with error \(error)")
            }
        }
    }

    func setPIN(pin: String, otp: String, completion: @escaping (Bool) -> Void) {
        IDKit.setPIN(pin: pin, otp: otp) { result in
            switch result {
            case .success(let successful):
                completion(successful)
                NSLog("Setting PIN with otp successful: \(successful)")

            case .failure(let error):
                completion(false)
                NSLog("Setting PIN with otp failed with error \(error)")
            }
        }
    }

    func setPIN(pin: String, password: String, completion: @escaping (Bool) -> Void) {
        IDKit.setPIN(pin: pin, password: password) { result in
            switch result {
            case .success(let successful):
                completion(successful)
                NSLog("Setting PIN with password successful: \(successful)")

            case .failure(let error):
                completion(false)
                NSLog("Setting PIN with password failed with error \(error)")
            }
        }
    }

    func disableBiometricAuthentication() {
        IDKit.disableBiometricAuthentication()
        NSLog("Biometry disabled")
    }

    func sendMailOTP(completion: @escaping (Bool?) -> Void) {
        IDKit.sendMailOTP { result in
            switch result {
            case .success(let successful):
                completion(successful)
                NSLog("OTP Mail sent successfully: \(successful)")

            case .failure(let error):
                completion(nil)
                NSLog("Sending OTP Mail failed with error \(error)")
            }
        }
    }
}
