//
//  ListViewRow.swift
//  PACECloudSDKExample
//
//  Created by PACE Telematics GmbH.
//

import Foundation
import PACECloudSDK
import SwiftUI

struct ListViewRow<T: ListViewModel>: View {
    @ObservedObject private var viewModel: T
    private let cofuStation: ListGasStation

    init(viewModel: T, cofuStation: ListGasStation) {
        self.viewModel = viewModel
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
                viewModel.selectedCofuStationId = cofuStation.id
            }, label: {
                Image(systemName: "chevron.right")
                    .font(.body)
                    .foregroundColor(.black)
            })
        }
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
    }
}
