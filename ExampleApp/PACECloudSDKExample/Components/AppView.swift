//
//  AppView.swift
//  PACECloudSDKExample
//
//  Created by PACE Telematics GmbH.
//

import PACECloudSDK
import SwiftUI

struct AppView: UIViewControllerRepresentable {
    private var presetUrl: PACECloudSDK.URL?
    private var customUrl: String?

    init(presetUrl: PACECloudSDK.URL) {
        self.presetUrl = presetUrl
    }

    init(customUrl: String) {
        self.customUrl = customUrl
    }

    func makeUIViewController(context: Context) -> AppViewController {
        if let presetUrl = presetUrl {
            return AppKit.appViewController(presetUrl: presetUrl)
        } else if let customUrl = customUrl {
            return AppKit.appViewController(appUrl: customUrl)
        } else {
            return AppKit.appViewController(appUrl: "")
        }
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}
