//
//  ListView.swift
//  PACECloudSDKExample
//
//  Created by PACE Telematics GmbH.
//

import Foundation
import PACECloudSDK
import SwiftUI

struct ListView<T: ListViewModel>: View {
    @ObservedObject private(set) var viewModel: T
    @State private var isFuelingViewControllerVisible = false
    @State private var showRadiusAlert: Bool = false

    init(viewModel: T) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            NavigationView {
                contentView
                    .padding([.bottom], .defaultPadding / 2)
                    .navigationTitle("CoFu Stations")
            }
            Spacer()
            Button(action: {
                showRadiusAlert = true
            }, label: {
                Text("Radius: \(viewModel.cofuStationRadius.formattedDistance(fractionDigits: 3))")
                    .foregroundColor(.brand)
                    .font(.system(size: 13))
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
            })

            Spacer()
                .frame(height: .defaultPadding / 2)
            RectangularButton(title: "Reload CoFu Stations", action: viewModel.fetchCofuStations)
                .padding([.leading, .trailing], .defaultPadding)
            Spacer()
                .frame(height: .defaultPadding / 2)
        }
        .alert(isPresented: $showRadiusAlert,
               TextFieldAlert(title: "Enter radius in meters",
                              textFields: [
                                .init(placeholder: "Radius", keyboardType: .numberPad)
                              ],
                              action: { texts in
                                guard !texts.isEmpty,
                                      let radiusString = texts[0],
                                      let radius = Double(radiusString) else {
                                    return
                                }

                                viewModel.cofuStationRadius = radius
                              })
        )
    }

    @ViewBuilder
    var contentView: some View {
        if viewModel.isLoading {
            LoadingSpinner()
        } else if viewModel.didFail {
            ErrorView()
        } else {
            populatedListView
        }
    }

    var populatedListView: some View {
        List(viewModel.cofuStations, id: \.id) { station in
            ListViewRow(with: station)
        }
    }
}
