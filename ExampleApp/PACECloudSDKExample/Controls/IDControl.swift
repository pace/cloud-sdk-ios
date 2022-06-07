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
        IDKit.resetSession { [weak self] result in
            switch result {
            case .success():
                self?.updateSessionInformation()

            case .failure(let error):
                ExampleLogger.w(error.description)
            }
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
                    ExampleLogger.w("Token invalid")
                    return
                }
                self?.userInfo()

            case .failure(let error):
                ExampleLogger.e("Failed authorizing with error \(error)")
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
                    ExampleLogger.w("Token invalid")
                    return
                }

            case .failure(let error):
                ExampleLogger.e("Failed refreshing with error \(error)")
            }

            self?.updateSessionInformation()
        }
    }

    func userInfo() {
        IDKit.userInfo { result in
            switch result {
            case .success(let userInfo):
                ExampleLogger.i("Did reveice user info \(userInfo)")

            case .failure(let error):
                ExampleLogger.e("UserInfo error \(error)")
            }
        }
    }

    func isPINSet(completion: @escaping (Bool?) -> Void) {
        IDKit.isPINSet { result in
            switch result {
            case .success(let isSet):
                completion(isSet)
                ExampleLogger.i("Is pin set: \(isSet)")

            case .failure(let error):
                completion(nil)
                ExampleLogger.e("IsPINSet failed with error \(error)")
            }
        }
    }

    func isPasswordSet(completion: @escaping (Bool?) -> Void) {
        IDKit.isPasswordSet { result in
            switch result {
            case .success(let isSet):
                completion(isSet)
                ExampleLogger.i("Is password set: \(isSet)")

            case .failure(let error):
                completion(nil)
                ExampleLogger.e("IsPasswordSet failed with error \(error)")
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
                ExampleLogger.i("Enabling biometry with password successful: \(successful)")

            case .failure(let error):
                completion(false)
                ExampleLogger.e("Enabling biometry with password failed with error \(error)")
            }
        }
    }

    func enableBiometricAuthentication(pin: String, completion: @escaping (Bool) -> Void) {
        IDKit.enableBiometricAuthentication(pin: pin) { result in
            switch result {
            case .success(let successful):
                completion(successful)
                ExampleLogger.i("Enabling biometry with pin successful: \(successful)")

            case .failure(let error):
                completion(false)
                ExampleLogger.e("Enabling biometry with pin failed with error \(error)")
            }
        }
    }

    func enableBiometricAuthentication(otp: String, completion: @escaping (Bool) -> Void) {
        IDKit.enableBiometricAuthentication(otp: otp) { result in
            switch result {
            case .success(let successful):
                completion(successful)
                ExampleLogger.i("Enabling biometry with otp successful: \(successful)")

            case .failure(let error):
                completion(false)
                ExampleLogger.e("Enabling biometry with otp failed with error \(error)")
            }
        }
    }

    func setPIN(pin: String, otp: String, completion: @escaping (Bool) -> Void) {
        IDKit.setPIN(pin: pin, otp: otp) { result in
            switch result {
            case .success(let successful):
                completion(successful)
                ExampleLogger.i("Setting PIN with otp successful: \(successful)")

            case .failure(let error):
                completion(false)
                ExampleLogger.e("Setting PIN with otp failed with error \(error)")
            }
        }
    }

    func setPIN(pin: String, password: String, completion: @escaping (Bool) -> Void) {
        IDKit.setPIN(pin: pin, password: password) { result in
            switch result {
            case .success(let successful):
                completion(successful)
                ExampleLogger.i("Setting PIN with password successful: \(successful)")

            case .failure(let error):
                completion(false)
                ExampleLogger.e("Setting PIN with password failed with error \(error)")
            }
        }
    }

    func disableBiometricAuthentication() {
        IDKit.disableBiometricAuthentication()
        ExampleLogger.i("Biometry disabled")
    }

    func sendMailOTP(completion: @escaping (Bool?) -> Void) {
        IDKit.sendMailOTP { result in
            switch result {
            case .success(let successful):
                completion(successful)
                ExampleLogger.i("OTP Mail sent successfully: \(successful)")

            case .failure(let error):
                completion(nil)
                ExampleLogger.e("Sending OTP Mail failed with error \(error)")
            }
        }
    }
}
