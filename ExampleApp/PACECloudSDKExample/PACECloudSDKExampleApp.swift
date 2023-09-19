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
                                                       clientId: "cloud-sdk-example-app",
                                                       environment: currentAppEnvironment,
                                                       domainACL: ["pace.cloud", "pacelink.net", "fuel.site"],
                                                       geoAppsScope: "pace-drive-ios-min",
                                                       logLevel: .debug,
                                                       persistLogs: true)

        PACECloudSDK.shared.setup(with: config)
        IDControl.shared.refresh()
    }

    var body: some Scene {
        WindowGroup {
            if idControl.isRefreshing {
                LoadingSpinner(loadingText: "Logging in...")
            } else if idControl.isSessionValid {
                MainTabView().onOpenURL { url in
                    PACECloudSDK.shared.application(open: url)
                }
            } else {
                LoginView()
            }
        }
    }
}

var currentAppEnvironment: PACECloudSDK.Environment {
    #if PRODUCTION
    return .production
    #elseif SANDBOX
    return .sandbox
    #else
    return .development
    #endif
}
