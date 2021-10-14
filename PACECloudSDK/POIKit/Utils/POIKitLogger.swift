//
//  POIKitLogger.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

class POIKitLogger: Logger {
    override class var logTag: String {
        Constants.logTag
    }

    override class var moduleTag: String {
        POIKitConstants.logTag
    }
}
