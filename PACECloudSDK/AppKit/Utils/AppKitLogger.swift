//
//  AppKitLogger.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

class AppKitLogger: Logger {
    override class var logTag: String {
        Constants.logTag
    }

    override class var moduleTag: String {
        AppKit.Constants.logTag
    }
}
