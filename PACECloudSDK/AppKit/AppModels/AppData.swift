//
//  AppData.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

public extension AppKit {
    class AppData: Equatable {
        private(set) public var appID: String?
        private(set) public var title: String?
        private(set) public var subtitle: String?
        internal(set) public var userDistance: Double?
        internal(set) public var userLocationAccuracy: Double?
        public let appBaseUrl: String?

        public let metadata: [AppKit.AppMetadata: AnyHashable]

        internal(set) public var appManifest: AppManifest? {
            didSet {
                guard let manifest = self.appManifest else { return }
                self.title = manifest.name
                self.subtitle = manifest.description
            }
        }

        internal(set) public var appStartUrl: String?

        // Since the responses from the geo do not have a pwa id
        // We need another identifier for an appdata object
        public var poiId: String {
            (metadata[AppMetadata.references] as? [String])?.first ?? ""
        }

        internal var shouldShowDistance: Bool = false

        init(appID: String?, title: String?, subtitle: String?, appUrl: String?, metadata: [AppKit.AppMetadata: AnyHashable]) {
            self.appID = appID
            self.title = title
            self.subtitle = subtitle
            self.appBaseUrl = appUrl
            self.metadata = metadata
        }

        init(appID: String?, appUrl: String?, metadata: [AppKit.AppMetadata: AnyHashable]) {
            self.appID = appID
            self.appBaseUrl = appUrl
            self.metadata = metadata
        }

        public static func == (lhs: AppData, rhs: AppData) -> Bool {
            return
                lhs.appID == rhs.appID &&
                lhs.title == rhs.title &&
                lhs.subtitle == rhs.subtitle &&
                lhs.appBaseUrl == rhs.appBaseUrl &&
                lhs.metadata == rhs.metadata &&
                lhs.appManifest == rhs.appManifest &&
                lhs.appStartUrl == rhs.appStartUrl
        }
    }
}
