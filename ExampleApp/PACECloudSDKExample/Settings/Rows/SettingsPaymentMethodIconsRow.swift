//
//  SettingsPaymentMethodIconsRow.swift
//  PACECloudSDKExample
//
//  Created by PACE Telematics GmbH.
//

import Foundation
import SwiftUI

struct SettingsPaymentMethodIconsRow: SettingsRow {
    private let title: String
    @State private var showPaymentMethodIcons: Bool = false

    init() {
        self.title = "Payment Method Icons"
    }

    var body: some View {
        ZStack {
            NavigationLink("", isActive: $showPaymentMethodIcons) {
                PaymentMethodIconsView(viewModel: SettingsViewModelImplementation())
            }
            .hidden()
            Button {
                showPaymentMethodIcons = true
            } label: {
                HStack {
                    StyledText(title)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.body)
                        .foregroundColor(.black)
                }
            }
        }
    }
}
