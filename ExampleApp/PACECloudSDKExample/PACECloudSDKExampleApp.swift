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

    private var databaseUrl: URL {
        do {
            let fileManager = FileManager.default
            let appSupportURL = try fileManager.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true)
            let directoryURL = appSupportURL.appendingPathComponent("GeoDatabase", isDirectory: true)
            try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)

            let databaseURL = directoryURL.appendingPathComponent("db.sqlite")
            return databaseURL
        } catch {
            fatalError("[ExampleApp] Invalid geo database url")
        }
    }

    init() {
        let config: PACECloudSDK.Configuration = .init(apiKey: "apikey",
                                                       clientId: "cloud-sdk-example-app",
                                                       geoDatabaseMode: .enabled(databaseUrl),
                                                       environment: currentAppEnvironment,
                                                       domainACL: ["pace.cloud", "pacelink.net", "fuel.site"],
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
