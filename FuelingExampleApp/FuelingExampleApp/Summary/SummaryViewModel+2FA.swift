//
//  SummaryViewModel+2FA.swift
//  FuelingExampleApp
//
//  Created by PACE Telematics GmbH.
//

import Foundation
import PACECloudSDK

extension SummaryViewModelImplementation {
    func handlePaymentAuthorizationIfNeeded(paymentMethod: PCFuelingPaymentMethod, completion: @escaping (PaymentAuthorization?) -> Void) {
        guard paymentMethod.twoFactor == true else {
            completion(nil)
            return
        }

        paymentAuthorizationCompletion = completion
        showPaymentAuthorizationAlert.value = true
    }

    func handlePaymentAuthorization(type: PaymentAuthorizationType, input: String?) {
        switch type {
        case .biometry:
            generateOTPWithBiometry { [weak self] result in
                self?.handleOTPResult(result: result, type: type)
            }

        case .pin:
            guard let pin = input else {
                showPaymentErrorAlert(message: "Please enter a valid PIN.")
                return
            }

            generateOTP(pin: pin) { [weak self] result in
                self?.handleOTPResult(result: result, type: type)
            }

        case .password:
            guard let password = input else {
                showPaymentErrorAlert(message: "Please enter a valid password.")
                return
            }

            generateOTP(password: password) { [weak self] result in
                self?.handleOTPResult(result: result, type: type)
            }
        }
    }

    private func handleOTPResult(result: Result<String, IDKit.IDKitError>, type: PaymentAuthorizationType) {
        if case .success(let otp) = result {
            let paymentAuthorization = PaymentAuthorization(otp: otp, method: type.rawValue)
            paymentAuthorizationCompletion?(paymentAuthorization)
        } else {
            showPaymentErrorAlert(message: Constants.genericErrorMessage)
        }

        paymentAuthorizationCompletion = nil
    }
}

// MARK: - API requests
private extension SummaryViewModelImplementation {
    func generateOTPWithBiometry(completion: @escaping (Result<String, IDKit.IDKitError>) -> Void) {
        IDKit.generateOTPWithBiometry { result in
            switch result {
            case .success(let otp):
                completion(.success(otp))

            case .failure(let error):
                if case .invalidSession = error {
                    NSLog("[SummaryViewModel] Failed refreshing the session. Will reset and attempt a new sign in...")
                    completion(.failure(.invalidSession))
                } else {
                    NSLog("[SummaryViewModel] Failed generating OTP with biometry with error \(error)")
                    completion(.failure(error))
                }
            }
        }
    }

    func generateOTP(pin: String, completion: @escaping (Result<String, IDKit.IDKitError>) -> Void) {
        IDKit.generateOTP(pin: pin) { result in
            switch result {
            case .success(let otp):
                completion(.success(otp))

            case .failure(let error):
                if case .invalidSession = error {
                    NSLog("[SummaryViewModel] Failed refreshing the session. Will reset and attempt a new sign in...")
                    completion(.failure(.invalidSession))
                } else {
                    NSLog("[SummaryViewModel] Failed generating OTP with pin with error \(error)")
                    completion(.failure(error))
                }
            }
        }
    }

    func generateOTP(password: String, completion: @escaping (Result<String, IDKit.IDKitError>) -> Void) {
        IDKit.generateOTP(password: password) { result in
            switch result {
            case .success(let otp):
                completion(.success(otp))

            case .failure(let error):
                if case .invalidSession = error {
                    NSLog("[SummaryViewModel] Failed refreshing the session. Will reset and attempt a new sign in...")
                    completion(.failure(.invalidSession))
                } else {
                    NSLog("[SummaryViewModel] Failed generating OTP with password with error \(error)")
                    completion(.failure(error))
                }
            }
        }
    }
}
