//
//  AppData.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

public extension AppKit {
    class AppData: Equatable {
        public let appID: String
        private(set) public var title: String?
        private(set) public var subtitle: String?
        public let appApiUrl: String?

        public let metadata: [AppKit.AppMetadata: AnyHashable]

        public var appManifest: AppManifest? {
            didSet {
                guard let manifest = self.appManifest else { return }
                self.title = manifest.name
                self.subtitle = manifest.description
            }
        }

        var appStartUrl: String?

        init(appID: String, title: String?, subtitle: String?, appUrl: String?, metadata: [AppKit.AppMetadata: AnyHashable]) {
            self.appID = appID
            self.title = title
            self.subtitle = subtitle
            self.appApiUrl = appUrl
            self.metadata = metadata
        }

        init(appID: String, appUrl: String?, metadata: [AppKit.AppMetadata: AnyHashable]) {
            self.appID = appID
            self.appApiUrl = appUrl
            self.metadata = metadata
        }

        public static func == (lhs: AppData, rhs: AppData) -> Bool {
            return
                lhs.appID == rhs.appID &&
                lhs.title == rhs.title &&
                lhs.subtitle == rhs.subtitle &&
                lhs.appApiUrl == rhs.appApiUrl &&
                lhs.metadata == rhs.metadata &&
                lhs.appManifest == rhs.appManifest &&
                lhs.appStartUrl == rhs.appStartUrl
        }
    }
}
