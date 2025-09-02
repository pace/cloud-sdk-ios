//
//  GeoMetadata.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation
internal import GRDB

extension GeoAPIManager.GeoDatabase {
    struct GeoMetadata: Codable, FetchableRecord, PersistableRecord {
        static let eTagKey = "etag"

        let key: String
        let value: String
    }
}
