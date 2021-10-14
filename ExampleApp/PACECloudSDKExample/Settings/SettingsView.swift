//
//  SettingsView.swift
//  PACECloudSDKExample
//
//  Created by PACE Telematics GmbH.
//

import Foundation
import SwiftUI
import Zip

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
        }.onTapGesture(count: 5, perform: {
            showDebugBundleActionSheet()
        })
    }

    func showDebugBundleActionSheet() {
        ExampleLogger.debugBundleDirectory { url in
            guard let debugBundleDirectory = url,
                  let debugBundle = try? Zip.quickZipFiles([debugBundleDirectory],
                                                           fileName: "example_debug_bundle") else {
                return
            }

            DispatchQueue.main.async {
                let shareObject = ShareObject(shareData: debugBundle, customTitle: "PACECloudSDKExample Debug Bundle")

                let activityVC = UIActivityViewController(activityItems: [shareObject], applicationActivities: nil)
                UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)
            }
        }
    }
}
