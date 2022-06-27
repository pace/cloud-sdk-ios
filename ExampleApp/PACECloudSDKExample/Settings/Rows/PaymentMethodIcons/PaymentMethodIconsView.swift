//
//  PaymentMethodIconsView.swift
//  PACECloudSDKExample
//
//  Created by PACE Telematics GmbH.
//

import Foundation
import SwiftUI

struct PaymentMethodIconsView<T: SettingsViewModel>: View {
    @ObservedObject private var viewModel: T

    init(viewModel: T) {
        self.viewModel = viewModel
    }

    var body: some View {
        List {
            PaymentMethodKindsRow(viewModel: viewModel)
            PaymentMethodVendorsRow(viewModel: viewModel)
        }
        .navigationTitle("Payment Method Icons")
    }
}
