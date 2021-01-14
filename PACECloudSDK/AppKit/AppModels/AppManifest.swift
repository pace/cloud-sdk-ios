//
//  AppManifest.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

public class AppManifest: Decodable, Equatable {
    public let name: String?
    public let shortName: String?
    public let description: String?
    public let icons: [AppIcon]?
    public let appStartUrl: String?

    public let iconBackgroundColor: String?
    public let textColor: String?
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

    public static func == (lhs: AppManifest, rhs: AppManifest) -> Bool {
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

public struct AppIcon: Decodable {
    let source: String?
    let sizes: String?
    let type: String?

    private enum CodingKeys: String, CodingKey {
        case sizes, type
        case source = "src"
    }
}
