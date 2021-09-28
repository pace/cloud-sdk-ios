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
    @State private var showSecurity: Bool = false

    init() {
        self.title = "Security"
    }

    var body: some View {
        ZStack {
            NavigationLink("", isActive: $showSecurity) {
                SecurityView(viewModel: SettingsViewModelImplementation())
            }
            .hidden()
            Button {
                showSecurity = true
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
