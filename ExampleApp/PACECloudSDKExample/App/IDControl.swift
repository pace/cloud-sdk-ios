//
//  IDControl.swift
//  PACECloudSDKExample
//
//  Created by Patrick Niepel on 06.11.20.
//

import PACECloudSDK
import UIKit

protocol IDControlDelegate: AnyObject {
    func didReceiveUserInfo(_ userInfo: IDKit.UserInfo)
}

class IDControl {
    static var shared = IDControl()
    weak var delegate: IDControlDelegate?

    private init() {}

    func setup(for navigationController: UINavigationController) {
        let config = IDKit.OIDConfiguration(authorizationEndpoint: "https://\(Constants.paceIDHost)/auth/realms/pace/protocol/openid-connect/auth",
                                            tokenEndpoint: "https://\(Constants.paceIDHost)/auth/realms/pace/protocol/openid-connect/token",
                                            userEndpoint: "https://\(Constants.paceIDHost)/auth/realms/pace/protocol/openid-connect/userinfo",
                                            clientId: "cloud-sdk-example-app",
                                            redirectUrl: "pace://cloud-sdk-example")

        IDKit.setup(with: config, cacheSession: true, presentingViewController: navigationController)
    }

    func authorize() {
        IDKit.authorize { [weak self] accessToken, error in
            if let error = error {
                NSLog("Failed authorizing with error \(error)")
            }

            guard let token = accessToken, !token.isEmpty else {
                NSLog("Token invalid")
                return
            }

            self?.userInfo()
        }
    }

    func refresh(_ completion: @escaping ((String) -> Void)) {
        IDKit.refreshToken { accessToken, error in
            if let error = error {
                NSLog("Failed refreshing with error \(error)")
            }

            guard let token = accessToken, !token.isEmpty else {
                NSLog("Token invalid")
                return
            }

            completion(token)
        }
    }

    func reset() {
        IDKit.resetSession()
    }

    func userInfo() {
        IDKit.userInfo { [weak self] userInfo, error in
            if let error = error {
                NSLog("UserInfo error \(error)")
            }

            guard let userInfo = userInfo else { return }

            self?.delegate?.didReceiveUserInfo(userInfo)
        }
    }

    func isPINSet() {
        IDKit.isPINSet { result in
            switch result {
            case .success(let isSet):
                NSLog("Is pin set: \(isSet)")

            case .failure(let error):
                NSLog("IsPINSet failed with error \(error)")
            }
        }
    }

    func isPasswordSet() {
        IDKit.isPasswordSet { result in
            switch result {
            case .success(let isSet):
                NSLog("Is password set: \(isSet)")

            case .failure(let error):
                NSLog("IsPasswordSet failed with error \(error)")
            }
        }
    }

    func isPINOrPasswordSet() {
        IDKit.isPINOrPasswordSet { result in
            switch result {
            case .success(let isSet):
                NSLog("Is pin or password set: \(isSet)")

            case .failure(let error):
                NSLog("IsPINOrPasswordSet failed with error \(error)")
            }
        }
    }

    func setPIN(pin: String, otp: String) {
        IDKit.setPIN(pin: pin, otp: otp) { result in
            switch result {
            case .success(let successful):
                NSLog("Setting PIN with otp successful: \(successful)")

            case .failure(let error):
                NSLog("Setting PIN with otp failed with error \(error)")
            }
        }
    }

    func setPIN(pin: String, password: String) {
        IDKit.setPIN(pin: pin, password: password) { result in
            switch result {
            case .success(let successful):
                NSLog("Setting PIN with password successful: \(successful)")

            case .failure(let error):
                NSLog("Setting PIN with password failed with error \(error)")
            }
        }
    }

    func setPINWithBiometry(pin: String) {
        IDKit.setPINWithBiometry(pin: pin) { result in
            switch result {
            case .success(let successful):
                NSLog("Setting PIN with biometry successful: \(successful)")

            case .failure(let error):
                NSLog("Setting PIN with biometry failed with error \(error)")
            }
        }
    }

    func isBiometrySet() {
        let enabled = IDKit.isBiometricAuthenticationEnabled()
        NSLog("Is biometry enabled: \(enabled)")
    }

    func enableBiometry() {
        IDKit.enableBiometricAuthentication { result in
            switch result {
            case .success(let successful):
                NSLog("Enabling biometry after login successful: \(successful)")

            case .failure(let error):
                NSLog("Enabling biometry after login failed with error \(error)")
            }
        }
    }

    func enableBiometry(otp: String) {
        IDKit.enableBiometricAuthentication(otp: otp) { result in
            switch result {
            case .success(let successful):
                NSLog("Enabling biometry with otp successful: \(successful)")

            case .failure(let error):
                NSLog("Enabling biometry with otp failed with error \(error)")
            }
        }
    }

    func enableBiometry(pin: String) {
        IDKit.enableBiometricAuthentication(pin: pin) { result in
            switch result {
            case .success(let successful):
                NSLog("Enabling biometry with pin successful: \(successful)")

            case .failure(let error):
                NSLog("Enabling biometry with pin failed with error \(error)")
            }
        }
    }

    func enableBiometry(password: String) {
        IDKit.enableBiometricAuthentication(password: password) { result in
            switch result {
            case .success(let successful):
                NSLog("Enabling biometry with password successful: \(successful)")

            case .failure(let error):
                NSLog("Enabling biometry with password failed with error \(error)")
            }
        }
    }

    func disableBiometry() {
        IDKit.disableBiometricAuthentication()
        NSLog("Biometry disabled")
    }

    func sendMailOTP() {
        IDKit.sendMailOTP { result in
            switch result {
            case .success(let successful):
                NSLog("OTP Mail sent successfully: \(successful)")

            case .failure(let error):
                NSLog("Sending OTP Mail failed with error \(error)")
            }
        }
    }
}
