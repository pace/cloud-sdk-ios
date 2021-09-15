//
//  SettingsLogoutRow.swift
//  PACECloudSDKExample
//
//  Created by PACE Telematics GmbH.
//

import Foundation
import SwiftUI

struct SettingsLogoutRow<T: SettingsViewModel>: SettingsRow {
    private let viewModel: T
    private let title: String

    init(viewModel: T) {
        self.viewModel = viewModel
        self.title = "Logout"
    }

    var body: some View {
        HStack {
            StyledText(title)
            Spacer()
            Button(action: {
                viewModel.logout()
            }, label: {
                Image(systemName: "chevron.right")
                    .font(.body)
                    .foregroundColor(.black)
            })
        }
    }
}
