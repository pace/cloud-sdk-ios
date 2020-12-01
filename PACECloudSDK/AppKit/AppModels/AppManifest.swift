//
//  AppManifest.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

class AppManifest: Decodable, Equatable {
    let name: String?
    let shortName: String?
    let description: String?
    let icons: [AppIcon]?
    let appStartUrl: String?

    let iconBackgroundColor: String?
    let textColor: String?
    let themeColor: String?

    var manifestUrl: String?

    private enum CodingKeys: String, CodingKey {
        case name, description, icons
        case shortName = "short_name"
        case iconBackgroundColor = "background_color"
        case appStartUrl = "pace_pwa_sdk_start_url"
        case textColor = "text_color"
        case themeColor = "theme_color"
    }

    static func == (lhs: AppManifest, rhs: AppManifest) -> Bool {
        return
            lhs.name == rhs.name &&
            lhs.shortName == rhs.shortName &&
            lhs.iconBackgroundColor == rhs.iconBackgroundColor &&
            lhs.description == rhs.description &&
            lhs.appStartUrl == rhs.appStartUrl &&
            lhs.manifestUrl == rhs.manifestUrl &&
            lhs.textColor == rhs.textColor &&
            lhs.themeColor == rhs.themeColor
    }
}

struct AppIcon: Decodable {
    let source: String?
    let sizes: String?
    let type: String?

    private enum CodingKeys: String, CodingKey {
        case sizes, type
        case source = "src"
    }
}
