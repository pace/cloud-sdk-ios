//
//  SettingsIsPoiInRangeRow.swift
//  PACECloudSDKExample
//
//  Created by PACE Telematics GmbH.
//

import Foundation
import SwiftUI

struct SettingsIsPoiInRangeRow<T: SettingsViewModel>: SettingsRow {
    private let viewModel: T
    private let title: String

    @State private var poiId: String = ""
    @State private var showPoiIdAlert: Bool = false
    @State private var showResultAlert: Bool = false
    @State private var resultAlertMessage: String = ""

    init(viewModel: T) {
        self.viewModel = viewModel
        self.title = "Is Poi In Range?"
    }

    var body: some View {
        Button(action: {
            showPoiIdAlert = true
        }, label: {
            StyledText(title)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.body)
        })
        .foregroundColor(.black)
        .alert(isPresented: $showPoiIdAlert,
               TextFieldAlert(title: "Enter POI ID", action: { texts in
                guard !texts.isEmpty else { return }
                if let poiId = texts[0] {
                    checkIfPoiIsInRange(with: poiId)
                }
               })
        )
        .alert(isPresented: $showResultAlert, content: {
            Alert(title: Text(resultAlertMessage), dismissButton: .default(Text("OK")))
        })
    }

    private func checkIfPoiIsInRange(with id: String) {
        viewModel.isPoiInRange(with: id) { isInRange in
            resultAlertMessage = isInRange ? "In Range" : "Not In Range"
            showResultAlert = true
        }
    }
}
