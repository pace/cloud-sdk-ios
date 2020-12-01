//
//  AppDataMock.swift
//  AppKitTests
//
//  Created by PACE Telematics GmbH.
//

import Foundation
@testable import PACECloudSDK

struct AppDataMock {
    static let appID = "appID"
    static let title = "title"
    static let subtitle = "subtitle"
    static let appUrl = "appUrl"
    static let metadata = [AppMetadata.appId: appID, AppMetadata.references: "references"]
    static let appData = AppKit.AppData(appID: "appID", title: "title", subtitle: "subtitle", appUrl: "appUrl", metadata: metadata)
}
