//
//  PaymentMethodVendorsRow.swift
//  PACECloudSDKExample
//
//  Created by PACE Telematics GmbH.
//

import Foundation
import SwiftUI

struct PaymentMethodVendorsRow<T: SettingsViewModel>: SettingsRow {
    private let viewModel: T
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""

    private let title: String

    init(viewModel: T) {
        self.viewModel = viewModel
        self.title = "Fetch Icons Via Vendors"
    }

    var body: some View {
        HStack {
            StyledText(title)
            Spacer()
            Button(action: {
                viewModel.fetchIconsViaPaymentMethodVendors { isSuccessful in
                    alertMessage = isSuccessful ? "Successfully requested vendors and icons." : "Failed fetching vendors and icons"
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
