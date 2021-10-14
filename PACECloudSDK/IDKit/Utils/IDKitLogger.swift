//
//  IDKitLogger.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

class IDKitLogger: Logger {
    override class var logTag: String {
        Constants.logTag
    }

    override class var moduleTag: String {
        IDKitConstants.logTag
    }
}
