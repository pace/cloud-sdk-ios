//
//  IDKitLogger.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

class IDKitLogger: Logger {
    override class var moduleTag: String {
        IDKitConstants.logTag
    }
}
