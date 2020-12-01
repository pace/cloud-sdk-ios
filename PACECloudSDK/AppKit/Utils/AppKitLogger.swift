//
//  AppKitLogger.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

class AppKitLogger: Logger {
    override class var moduleTag: String {
        AppKitConstants.logTag
    }
}
