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
        Task { @MainActor [weak self] in
            let result = await IDKit.resetSession()

            switch result {
            case .success:
                self?.updateSessionInformation()

            case .failure(let error):
                ExampleLogger.w(error.description)
            }
        }
    }

    func isAuthorizationValid() -> Bool {
        IDKit.isAuthorizationValid()
    }

    func latestAccessToken() -> String? {
        IDKit.latestAccessToken()
    }

    func updateSessionInformation() {
        isSessionValid = IDKit.isAuthorizationValid()
    }

    func authorize(with viewController: UIViewController) {
        IDKit.presentingViewController = viewController
        Task { @MainActor [weak self] in
            let result = await IDKit.authorize()

            switch result {
            case .success(let accessToken):
                guard let token = accessToken, !token.isEmpty else {
                    ExampleLogger.w("Token invalid")
                    return
                }

            case .failure(let error):
                ExampleLogger.e("Failed authorizing with error \(error)")
            }

            self?.updateSessionInformation()
        }
    }

    func refresh() {
        isRefreshing = true
        Task { @MainActor [weak self] in
            defer {
                self?.isRefreshing = false
            }

            let result = await IDKit.refreshToken()

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

    func userInfo() async -> IDKit.UserInfo? {
        let result = await IDKit.userInfo()

        switch result {
        case .success(let userInfo):
            ExampleLogger.i("Did reveice user info \(userInfo)")
            return userInfo

        case .failure(let error):
            ExampleLogger.e("UserInfo error \(error)")
            return nil
        }
    }

    func isPINSet() async -> Bool? {
        let result = await IDKit.isPINSet()

        switch result {
        case .success(let isSet):
            ExampleLogger.i("Is pin set: \(isSet)")
            return isSet

        case .failure(let error):
            ExampleLogger.e("IsPINSet failed with error \(error)")
            return nil
        }
    }

    func isPasswordSet() async -> Bool? {
        let result = await IDKit.isPasswordSet()

        switch result {
        case .success(let isSet):
            ExampleLogger.i("Is password set: \(isSet)")
            return isSet

        case .failure(let error):
            ExampleLogger.e("IsPasswordSet failed with error \(error)")
            return nil
        }
    }

    func isBiometricAuthenticationEnabled() -> Bool {
        IDKit.isBiometricAuthenticationEnabled()
    }

    func enableBiometricAuthentication(password: String) async -> Bool {
        let result = await IDKit.enableBiometricAuthentication(password: password)

        switch result {
        case .success(let successful):
            ExampleLogger.i("Enabling biometry with password successful: \(successful)")
            return successful

        case .failure(let error):
            ExampleLogger.e("Enabling biometry with password failed with error \(error)")
            return false
        }
    }

    func enableBiometricAuthentication(pin: String) async -> Bool {
        let result = await IDKit.enableBiometricAuthentication(pin: pin)

        switch result {
        case .success(let successful):
            ExampleLogger.i("Enabling biometry with pin successful: \(successful)")
            return successful

        case .failure(let error):
            ExampleLogger.e("Enabling biometry with pin failed with error \(error)")
            return false
        }
    }

    func enableBiometricAuthentication(otp: String) async -> Bool {
        let result = await IDKit.enableBiometricAuthentication(otp: otp)

        switch result {
        case .success(let successful):
            ExampleLogger.i("Enabling biometry with otp successful: \(successful)")
            return successful

        case .failure(let error):
            ExampleLogger.e("Enabling biometry with otp failed with error \(error)")
            return false
        }
    }

    func setPIN(pin: String, otp: String) async -> Bool {
        let result = await IDKit.setPIN(pin: pin, otp: otp)

        switch result {
        case .success(let successful):
            ExampleLogger.i("Setting PIN with otp successful: \(successful)")
            return successful

        case .failure(let error):
            ExampleLogger.e("Setting PIN with otp failed with error \(error)")
            return false
        }
    }

    func setPIN(pin: String, password: String) async -> Bool {
        let result = await IDKit.setPIN(pin: pin, password: password)

        switch result {
        case .success(let successful):
            ExampleLogger.i("Setting PIN with password successful: \(successful)")
            return successful

        case .failure(let error):
            ExampleLogger.e("Setting PIN with password failed with error \(error)")
            return false
        }
    }

    func disableBiometricAuthentication() {
        IDKit.disableBiometricAuthentication()
        ExampleLogger.i("Biometry disabled")
    }

    func sendMailOTP() async -> Bool? {
        let result = await IDKit.sendMailOTP()

        switch result {
        case .success(let successful):
            ExampleLogger.i("OTP Mail sent successfully: \(successful)")
            return successful

        case .failure(let error):
            ExampleLogger.e("Sending OTP Mail failed with error \(error)")
            return nil
        }
    }
}
