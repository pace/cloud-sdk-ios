//
//  SettingsAccountView.swift
//  PACECloudSDKExample
//
//  Created by PACE Telematics GmbH.
//

import Foundation
import SwiftUI

struct SettingsAccountView<T: SettingsViewModel>: SettingsRow {
    private let viewModel: T

    init(viewModel: T) {
        self.viewModel = viewModel
    }

    var body: some View {
        HStack {
            Image(systemName: "person.crop.circle.fill")
                .foregroundColor(.secondary)
            VStack(alignment: .leading) {
                StyledText("Signed in as:", style: .secondary)
                Text(viewModel.userEmail)
                    .foregroundColor(.brand)
                    .font(.system(size: 18, weight: .regular))
            }
            Spacer()
        }
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
    }
}
