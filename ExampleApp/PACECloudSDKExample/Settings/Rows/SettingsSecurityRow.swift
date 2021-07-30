//
//  SettingsSecurityRow.swift
//  PACECloudSDKExample
//
//  Created by PACE Telematics GmbH.
//

import Foundation
import SwiftUI

struct SettingsSecurityRow: SettingsRow {
    private let title: String

    init() {
        self.title = "Security"
    }

    var body: some View {
        ZStack {
            NavigationLink(
                destination: SecurityView(viewModel: SettingsViewModelImplementation()),
                label: {})
                .hidden()
            HStack {
                StyledText(title)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.body)
            }
        }

    }
}
