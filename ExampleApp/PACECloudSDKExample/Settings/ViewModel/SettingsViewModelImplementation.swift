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

    func fetchIconsViaPaymentMethodKinds(completion: @escaping (Bool) -> Void) {
        guard let accessToken = IDControl.shared.latestAccessToken() else {
            completion(false)
            return
        }

        let request = PayAPI.PaymentMethodKinds.GetPaymentMethodKinds.Request(additionalData: true)
        request.customHeaders = [HttpHeaderFields.authorization.rawValue: "Bearer \(accessToken)"]
        API.Pay.client.makeRequest(request) { [weak self] response in
            switch response.result {
            case .success(let result):
                guard let paymentMethodKinds = result.success?.data else {
                    ExampleLogger.e("[SettingsViewModelImplementation] Failed fetching payment method kinds - Invalid data.")
                    completion(false)
                    return
                }
                self?.fetchPaymentMethodIcons(for: paymentMethodKinds, completion: completion)

            case .failure(let error):
                ExampleLogger.e("[SettingsViewModelImplementation] Failed fetching payment method kinds with error \(error)")
                completion(false)
            }
        }
    }

    private func fetchPaymentMethodIcons(for paymentMethodKinds: PCPayPaymentMethodKinds, completion: @escaping (Bool) -> Void) {
        API.CDN.client.paymentMethodVendorIcons(for: paymentMethodKinds) { icons in
            ExampleLogger.i("[SettingsViewModelImplementation] Fetched icons for payment method kinds: \(icons)")
            completion(true)
        }
    }

    func fetchIconsViaPaymentMethodVendors(completion: @escaping (Bool) -> Void) {
        API.CDN.client.paymentMethodVendors { [weak self] result in
            switch result {
            case .success(let fetchedVendors):
                self?.fetchPaymentMethodIcons(for: fetchedVendors, completion: completion)

            case .failure(let error):
                ExampleLogger.e("[SettingsViewModelImplementation] Failed fetching payment method vendors with error \(error)")
                completion(false)
            }
        }
    }

    private func fetchPaymentMethodIcons(for paymentMethodVendors: PaymentMethodVendors, completion: @escaping (Bool) -> Void) {
        API.CDN.client.paymentMethodVendorIcons(for: paymentMethodVendors) { icons in
            ExampleLogger.i("[SettingsViewModelImplementation] Fetched icons for payment method vendors: \(icons)")
            completion(true)
        }
    }

    func logout() {
        IDControl.shared.reset()
    }

    func isPoiInRange(with id: String, completion: @escaping (Bool) -> Void) {
        AppControl.shared.isPoiInRange(with: id, completion: completion)
    }
}
