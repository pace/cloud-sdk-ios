//
//  SettingsPasswordStatusRow.swift
//  PACECloudSDKExample
//
//  Created by PACE Telematics GmbH.
//

import Foundation
import SwiftUI

struct SettingsPasswordStatusRow<T: SettingsViewModel>: SettingsRow {
    private let viewModel: T
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""

    private let title: String

    init(viewModel: T) {
        self.viewModel = viewModel
        self.title = "Is Password Set?"
    }

    var body: some View {
        HStack {
            StyledText(title)
            Spacer()
            Button(action: {
                viewModel.isPasswordSet { isSuccessful in
                    if let isSuccessful = isSuccessful {
                        alertMessage = isSuccessful ? "Password set" : "Password not set"
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
