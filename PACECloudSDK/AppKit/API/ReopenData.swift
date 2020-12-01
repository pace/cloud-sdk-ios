//
//  ReopenData.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

struct ReopenData {
    let reopenTitle: String?
    let reopenSubtitle: String?
    let reopenUrl: String?
    let state: String?

    init(from query: String) {
        let queryItems = URLDecomposer.decomposeQuery(query)
        self.init(from: queryItems)
    }

    init(from queryItems: [String: String]) {
        self.reopenTitle = queryItems[URLParam.reopenTitle.rawValue]
        self.reopenSubtitle = queryItems[URLParam.reopenSubtitle.rawValue]
        self.reopenUrl = queryItems[URLParam.reopenUrl.rawValue]
        self.state = queryItems[URLParam.state.rawValue]
    }
}
