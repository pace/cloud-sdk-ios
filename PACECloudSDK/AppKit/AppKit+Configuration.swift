//
//  AppKit+Configuration.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import UIKit

public extension AppKit {
    enum AppKitTheme: CustomStringConvertible {
        case dark
        case light
        case automatic

        public var description: String {
            switch self {
            case .dark:
                return "Dark"

            case .light:
                return "Light"

            case .automatic:
                if #available(iOS 13.0, *) {
                    return UITraitCollection.current.userInterfaceStyle == .light ? "\(AppKitTheme.light)" : "\(AppKitTheme.dark)"
                } else {
                    return "\(AppKitTheme.light)"
                }
            }
        }

        public var isDarkTheme: Bool {
            description == AppKitTheme.dark.description
        }
    }
}
