//
//  RedirectServiceData.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

struct RedirectServiceData {
    let to: String?

    init(from query: String) {
        let queryItems = URLDecomposer.decomposeQuery(query)
        self.init(from: queryItems)
    }

    init(from queryItems: [String: String]) {
        self.to = queryItems["to"]
    }
}
