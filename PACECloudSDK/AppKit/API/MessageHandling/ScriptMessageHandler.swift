//
//  ScriptMessageHandler.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

enum ScriptMessageHandler: String, CaseIterable {
    case nativeAPIWithReply = "pace_native_api_with_reply"
    case nativeAPI = "pace_native_api"
    case logger = "pace_logger"
}
