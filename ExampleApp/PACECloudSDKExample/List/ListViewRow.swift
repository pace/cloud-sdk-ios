//
//  ListViewRow.swift
//  PACECloudSDKExample
//
//  Created by PACE Telematics GmbH.
//

import Foundation
import PACECloudSDK
import SwiftUI

struct ListViewRow: View {
    private let cofuStation: ListGasStation
    @State private var isFuelingViewControllerVisible: Bool = false

    init(with cofuStation: ListGasStation) {
        self.cofuStation = cofuStation
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                StyledText(cofuStation.name)
                StyledText(cofuStation.addressLine1, style: .secondary)
                StyledText(cofuStation.addressLine2, style: .secondary)
            }
            Spacer()
            Text(cofuStation.formattedDistance)
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(.secondary)
            Button(action: {
                isFuelingViewControllerVisible = true
            }, label: {
                Image(systemName: "chevron.right")
                    .font(.body)
            })
            .sheet(isPresented: $isFuelingViewControllerVisible) {
                AppView(presetUrl: .fueling(id: cofuStation.id))
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
    }
}
