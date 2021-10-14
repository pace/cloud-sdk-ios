//
//  SDKLogger.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

class SDKLogger: Logger {
    override class var logTag: String {
        Constants.logTag
    }
}
