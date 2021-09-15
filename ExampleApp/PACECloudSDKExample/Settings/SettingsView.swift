//
//  SettingsView.swift
//  PACECloudSDKExample
//
//  Created by PACE Telematics GmbH.
//

import Foundation
import SwiftUI

struct SettingsView<T: SettingsViewModel>: View {
    @ObservedObject private var viewModel: T

    init(viewModel: T) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationView {
            List {
                Section {
                    SettingsAccountView(viewModel: viewModel)
                }
                Section {
                    SettingsSecurityRow()
                    SettingsPWASimulatorRow(viewModel: viewModel)
                    SettingsIsPoiInRangeRow(viewModel: viewModel)
                    SettingsLogoutRow(viewModel: viewModel)
                }
            }
            .listStyle(GroupedListStyle())
            .navigationTitle("Settings")
        }
    }
}
