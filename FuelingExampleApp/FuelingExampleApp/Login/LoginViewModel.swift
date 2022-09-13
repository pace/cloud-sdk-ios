//
//  LoginViewModel.swift
//  FuelingExampleApp
//
//  Created by PACE Telematics GmbH.
//

import PACECloudSDK
import UIKit

protocol LoginViewModel {
    var isLoading: LiveData<Bool> { get }
    var errorMessage: LiveData<String> { get }
    var showBiometricAuthenticationAlert: LiveData<Bool> { get }
    var didHandleBiometricAuthentication: LiveData<Bool> { get }
    func authorize(presentingViewController: UIViewController, completion: @escaping (String?) -> Void)
    func refresh(completion: @escaping (String?) -> Void)
    func askForBiometricAuthentication()
    func handleBiometricAuthentication(type: PaymentAuthorizationType, input: String?)
}

class LoginViewModelImplementation: LoginViewModel {
    private(set) var isLoading: LiveData<Bool> = .init(value: false)
    private(set) var errorMessage: LiveData<String> = .init()
    private(set) var showBiometricAuthenticationAlert: LiveData<Bool> = .init(value: false)
    private(set) var didHandleBiometricAuthentication: LiveData<Bool> = .init(value: false)

    func authorize(presentingViewController: UIViewController, completion: @escaping (String?) -> Void) {
        isLoading.value = true
        IDKit.presentingViewController = presentingViewController
        IDKit.authorize { [weak self] result in
            defer {
                self?.isLoading.value = false
            }

            switch result {
            case .success(let accessToken):
                guard let accessToken = accessToken else {
                    completion("[LoginViewModelImplementation] Failed authorization - token nil")
                    return
                }

                NSLog("[LoginViewModelImplementation] Successfully authorized with access token: \(accessToken)")
                completion(nil)

            case .failure(let error):
                if case .authorizationCanceled = error {} else {
                    NSLog("[LoginViewModelImplementation] Failed authorization with error \(error)")
                    completion(error.description)
                }
            }
        }
    }

    func refresh(completion: @escaping (String?) -> Void) {
        isLoading.value = true
        IDKit.refreshToken { [weak self] result in
            defer {
                self?.isLoading.value = false
            }

            switch result {
            case .success(let accessToken):
                guard let accessToken = accessToken else {
                    completion("[LoginViewModelImplementation] Failed refreshing access token - token nil")
                    return
                }

                NSLog("[LoginViewModelImplementation] Successfully refreshed access token: \(accessToken)")
                completion(nil)

            case .failure(let error):
                NSLog("[LoginViewModelImplementation] Failed refreshing access token with error \(error.description)")
                completion(error.description)
            }
        }
    }

    func askForBiometricAuthentication() {
        guard !IDKit.isBiometricAuthenticationEnabled() else {
            didHandleBiometricAuthentication.value = true
            return
        }

        showBiometricAuthenticationAlert.value = true
    }

    func handleBiometricAuthentication(type: PaymentAuthorizationType, input: String?) {
        switch type {
        case .pin:
            guard let pin = input else {
                showErrorAlert(message: "Please enter a valid PIN.")
                return
            }

            enableBiometricAuthentication(pin: pin) { [weak self] isEnabled in
                self?.handleBiometricAuthenticationResult(result: isEnabled)
            }

        case .password:
            guard let password = input else {
                showErrorAlert(message: "Please enter a valid password.")
                return
            }

            enableBiometricAuthentication(password: password) { [weak self] isEnabled in
                self?.handleBiometricAuthenticationResult(result: isEnabled)
            }

        default:
            return
        }
    }

    private func handleBiometricAuthenticationResult(result: Bool) {
        if result {
            didHandleBiometricAuthentication.value = true
        } else {
            showErrorAlert(message: Constants.genericErrorMessage)
        }
    }

    private func showErrorAlert(message: String) {
        errorMessage.value = message
    }
}

private extension LoginViewModelImplementation {
    func enableBiometricAuthentication(pin: String, completion: @escaping (Bool) -> Void) {
        IDKit.enableBiometricAuthentication(pin: pin) { result in
            switch result {
            case .success(let isSuccessful):
                completion(isSuccessful)

            case .failure(let error):
                completion(false)
                NSLog("[LoginViewModelImplementation] Failed enabling biometric authentication with pin with error \(error)")
            }
        }
    }

    func enableBiometricAuthentication(password: String, completion: @escaping (Bool) -> Void) {
        IDKit.enableBiometricAuthentication(password: password) { result in
            switch result {
            case .success(let isSuccessful):
                completion(isSuccessful)

            case .failure(let error):
                completion(false)
                NSLog("[LoginViewModelImplementation] Failed enabling biometric authentication with password with error \(error)")
            }
        }
    }
}
