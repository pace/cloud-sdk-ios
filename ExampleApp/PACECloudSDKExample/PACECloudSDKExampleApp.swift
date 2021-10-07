//
//  PACECloudSDKExampleApp.swift
//  PACECloudSDKExample
//
//  Created by PACE Telematics GmbH.
//

import PACECloudSDK
import SwiftUI

@main
struct PACECloudSDKExampleApp: App {
    @ObservedObject private var idControl = IDControl.shared

    init() {
        let config: PACECloudSDK.Configuration = .init(apiKey: "apikey",
                                                       environment: currentAppEnvironment,
                                                       domainACL: ["pace.cloud", "pacelink.net"],
                                                       geoAppsScope: "pace-drive-ios-min")

        PACECloudSDK.shared.setup(with: config)
        IDControl.shared.refresh()
    }

    var body: some Scene {
        WindowGroup {
            if idControl.isRefreshing {
                LoadingSpinner(loadingText: "Logging in...")
            } else if idControl.isSessionValid {
                MainTabView()
            } else {
                LoginView()
            }
        }
    }
}

var currentAppEnvironment: PACECloudSDK.Environment {
    #if PRODUCTION
    return .production
    #elseif STAGE
    return .stage
    #elseif SANDBOX
    return .sandbox
    #else
    return .development
    #endif
}
