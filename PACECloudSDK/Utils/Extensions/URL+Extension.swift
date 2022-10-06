//
//  URL+Extension.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

extension URL {
    var isHttpScheme: Bool {
        scheme == "http"
    }

    var isHttpsScheme: Bool {
        scheme == "https"
    }
}
