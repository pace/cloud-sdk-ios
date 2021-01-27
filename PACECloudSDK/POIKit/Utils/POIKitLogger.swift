//
//  POIKitLogger.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

class POIKitLogger: Logger {
    override class var moduleTag: String {
        POIKitConstants.logTag
    }
}
