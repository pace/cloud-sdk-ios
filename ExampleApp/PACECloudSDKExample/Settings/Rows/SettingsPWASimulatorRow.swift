//
//  SettingsPWASimulatorRow.swift
//  PACECloudSDKExample
//
//  Created by PACE Telematics GmbH.
//

import Foundation
import SwiftUI

struct SettingsPWASimulatorRow<T: SettingsViewModel>: SettingsRow {
    private let viewModel: T
    private let title: String

    @State private var isPWASimulatorAppVisible: Bool = false

    init(viewModel: T) {
        self.viewModel = viewModel
        self.title = "PWA Simulator"
    }

    var body: some View {
        HStack {
            StyledText(title)
            Spacer()
            Button(action: {
                isPWASimulatorAppVisible = true
            }, label: {
                Image(systemName: "chevron.right")
                    .font(.body)
                    .foregroundColor(.black)
            })
            .sheet(isPresented: $isPWASimulatorAppVisible) {
                AppView(customUrl: Constants.pwaSimulatorUrl)
            }
        }
    }
}
