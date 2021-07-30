//
//  SettingsBiometricAuthenticationRow.swift
//  PACECloudSDKExample
//
//  Created by PACE Telematics GmbH.
//

import Foundation
import SwiftUI

struct SettingsBiometricAuthenticationRow<T: SettingsViewModel>: SettingsRow {
    @ObservedObject private var viewModel: T

    @State private var isBiometricAuthenticationEnabled: Bool
    @State private var showBiometryAlert: Bool = false
    @State private var showResultAlert: Bool = false
    @State private var resultAlertMessage: String = ""

    private let title: String

    init(viewModel: T) {
        self.viewModel = viewModel
        self.title = "Biometric Authentication"
        self.isBiometricAuthenticationEnabled = viewModel.isBiometricAuthenticationEnabled
    }

    var body: some View {
        HStack {
            StyledText(title)
            Spacer()
            ToggleView(isOn: $isBiometricAuthenticationEnabled)
        }
        .onChange(of: isBiometricAuthenticationEnabled, perform: { value in
            if value && !viewModel.isBiometricAuthenticationEnabled {
                showBiometryAlert = true
            } else if !value && viewModel.isBiometricAuthenticationEnabled {
                disableBiometricAuthentication()
            }
        })
        .alert(isPresented: $showBiometryAlert,
               TextFieldAlert(title: "Confirmation required",
                              message: "Confirm the use of biometry with one of the options below",
                              textFields: [
                                .init(placeholder: "Password", keyboardType: .default),
                                .init(placeholder: "PIN", keyboardType: .numberPad),
                                .init(placeholder: "OTP", keyboardType: .numberPad)
                              ],
                              action: { texts in
                                guard !texts.isEmpty else {
                                    updateBiometryStatus()
                                    return
                                }
                                let password = texts[0]
                                let pin = texts[1]
                                let otp = texts[2]
                                enableBiometricAuthentication(password: password, pin: pin, otp: otp)
               })
        )
        .alert(isPresented: $showResultAlert, content: {
            Alert(title: Text(resultAlertMessage), dismissButton: .default(Text("OK")))
        })
    }

    private func enableBiometricAuthentication(password: String?, pin: String?, otp: String?) {
        viewModel.enableBiometricAuthentication(password: password, pin: pin, otp: otp) { isSuccessful in
            if let isSuccessful = isSuccessful {
                resultAlertMessage = isSuccessful ? "Activation successful" : "Activation failed"
            } else {
                resultAlertMessage = "The request failed"
            }
            showResultAlert = true
            updateBiometryStatus()
        }
    }

    private func disableBiometricAuthentication() {
        viewModel.disableBiometricAuthentication()
        resultAlertMessage = "Biometric authentication disabled"
        showResultAlert = true
        updateBiometryStatus()
    }

    private func updateBiometryStatus() {
        isBiometricAuthenticationEnabled = viewModel.isBiometricAuthenticationEnabled
    }
}
