//
//  SettingsMailOTPRow.swift
//  PACECloudSDKExample
//
//  Created by PACE Telematics GmbH.
//

import Foundation
import SwiftUI

struct SettingsMailOTPRow<T: SettingsViewModel>: SettingsRow {
    private let viewModel: T
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""

    private let title: String

    init(viewModel: T) {
        self.viewModel = viewModel
        self.title = "Mail OTP"
    }

    var body: some View {
        HStack {
            StyledText(title)
            Spacer()
            Button(action: {
                Task {
                    let isSuccessful = await viewModel.sendMailOTP()

                    if let isSuccessful = isSuccessful {
                        alertMessage = isSuccessful ? "Successfully sent mail otp." : "Failed sending the mail otp."
                    } else {
                        alertMessage = "The request failed"
                    }

                    showAlert = true
                }
            }, label: {
                Image(systemName: "chevron.right")
                    .font(.body)
                    .foregroundColor(.black)
            })
            .alert(isPresented: $showAlert) {
                Alert(title: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
}
