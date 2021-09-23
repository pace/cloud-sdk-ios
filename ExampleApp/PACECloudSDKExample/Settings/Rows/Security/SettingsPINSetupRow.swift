//
//  SettingsPINSetupRow.swift
//  PACECloudSDKExample
//
//  Created by PACE Telematics GmbH.
//

import Foundation
import SwiftUI

struct SettingsPINSetupRow<T: SettingsViewModel>: SettingsRow {
    @ObservedObject private var viewModel: T

    @State private var showPINSetupAlert: Bool = false
    @State private var showResultAlert: Bool = false
    @State private var resultAlertMessage: String = ""

    private let title: String

    init(viewModel: T) {
        self.viewModel = viewModel
        self.title = "PIN Setup"
    }

    var body: some View {
        Button(action: {
            showPINSetupAlert = true
        }, label: {
            StyledText(title)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.body)
                .foregroundColor(.black)
        })
        .alert(isPresented: $showPINSetupAlert,
               TextFieldAlert(title: "PIN Setup",
                              message: "Enter your PIN and confirm the setup with one of the options below",
                              textFields: [
                                .init(placeholder: "Enter PIN", keyboardType: .numberPad),
                                .init(placeholder: "Confirm with password", keyboardType: .default),
                                .init(placeholder: "Confirm with OTP", keyboardType: .numberPad)
                              ],
                              action: { texts in
                                guard !texts.isEmpty else { return }
                                let pin = texts[0] ?? ""
                                let password = texts[1]
                                let otp = texts[2]
                                setPIN(pin: pin, password: password, otp: otp)
                              })
        )
        .alert(isPresented: $showResultAlert, content: {
            Alert(title: Text(resultAlertMessage), dismissButton: .default(Text("OK")))
        })
    }

    private func setPIN(pin: String, password: String?, otp: String?) {
        viewModel.setPIN(pin: pin, password: password, otp: otp) { isSuccessful in
            resultAlertMessage = isSuccessful ? "PIN setup successful" : "PIN setup failed"
            showResultAlert = true
        }
    }
}
