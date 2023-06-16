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
        Task { @MainActor [weak self] in
            let userInfo = await IDControl.shared.userInfo()
            self?.userEmail = userInfo?.email ?? "Could not retrieve user info"
        }
    }

    func enableBiometricAuthentication(password: String?,
                                       pin: String?,
                                       otp: String?) async -> Bool? {
        if let password = password {
            return await IDControl.shared.enableBiometricAuthentication(password: password)
        } else if let pin = pin {
            return await IDControl.shared.enableBiometricAuthentication(pin: pin)
        } else if let otp = otp {
            return await IDControl.shared.enableBiometricAuthentication(otp: otp)
        } else {
            return false
        }
    }

    func disableBiometricAuthentication() {
        IDControl.shared.disableBiometricAuthentication()
    }

    func isPasswordSet() async -> Bool? {
        await IDControl.shared.isPasswordSet()
    }

    func isPINSet() async -> Bool? {
        await IDControl.shared.isPINSet()
    }

    func setPIN(pin: String, password: String?, otp: String?) async -> Bool {
        if let password = password {
            return await IDControl.shared.setPIN(pin: pin, password: password)
        } else if let otp = otp {
            return await IDControl.shared.setPIN(pin: pin, otp: otp)
        } else {
            return false
        }
    }

    func sendMailOTP() async -> Bool? {
        return await IDControl.shared.sendMailOTP()
    }

    func fetchIconsViaPaymentMethodKinds() async -> Bool {
        guard let accessToken = IDControl.shared.latestAccessToken() else {
            return false
        }

        let request = PayAPI.PaymentMethodKinds.GetPaymentMethodKinds.Request(additionalData: true)
        request.customHeaders = [HttpHeaderFields.authorization.rawValue: "Bearer \(accessToken)"]

        let response = await API.Pay.client.makeRequest(request)

        switch response.result {
        case .success(let result):
            guard let paymentMethodKinds = result.success?.data else {
                ExampleLogger.e("[SettingsViewModelImplementation] Failed fetching payment method kinds - Invalid data.")
                return false
            }
            return await fetchPaymentMethodIcons(for: paymentMethodKinds)

        case .failure(let error):
            ExampleLogger.e("[SettingsViewModelImplementation] Failed fetching payment method kinds with error \(error)")
            return false
        }
    }

    private func fetchPaymentMethodIcons(for paymentMethodKinds: PCPayPaymentMethodKinds) async -> Bool {
        let icons = await API.CDN.client.paymentMethodVendorIcons(for: paymentMethodKinds)
        ExampleLogger.i("[SettingsViewModelImplementation] Fetched icons for payment method kinds: \(icons)")
        return true
    }

    func fetchIconsViaPaymentMethodVendors() async -> Bool {
        let result = await API.CDN.client.paymentMethodVendors()

        switch result {
        case .success(let fetchedVendors):
            return await fetchPaymentMethodIcons(for: fetchedVendors)

        case .failure(let error):
            ExampleLogger.e("[SettingsViewModelImplementation] Failed fetching payment method vendors with error \(error)")
            return false
        }
    }

    private func fetchPaymentMethodIcons(for paymentMethodVendors: PaymentMethodVendors) async -> Bool {
        let icons = await API.CDN.client.paymentMethodVendorIcons(for: paymentMethodVendors)
        ExampleLogger.i("[SettingsViewModelImplementation] Fetched icons for payment method vendors: \(icons)")
        return true
    }

    func logout() {
        IDControl.shared.reset()
    }

    func isPoiInRange(with id: String) async -> Bool {
        await AppControl.shared.isPoiInRange(with: id)
    }
}
