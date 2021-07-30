//
//  SecurityView.swift
//  PACECloudSDKExample
//
//  Created by PACE Telematics GmbH.
//

import Foundation
import SwiftUI

struct SecurityView<T: SettingsViewModel>: View {
    @ObservedObject private var viewModel: T

    init(viewModel: T) {
        self.viewModel = viewModel
    }

    var body: some View {
        List {
            SettingsBiometricAuthenticationRow(viewModel: viewModel)
            SettingsPasswordStatusRow(viewModel: viewModel)
            SettingsPINStatusRow(viewModel: viewModel)
            SettingsPINSetupRow(viewModel: viewModel)
            SettingsMailOTPRow(viewModel: viewModel)
        }
        .navigationTitle("Security")
    }
}
