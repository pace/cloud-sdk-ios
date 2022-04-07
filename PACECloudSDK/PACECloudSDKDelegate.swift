//
//  PACECloudSDKDelegate.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

public protocol PACECloudSDKDelegate: AnyObject {
    func reportBreadcrumbs(_ message: String, parameters: [String: AnyHashable]?)
    func reportError(_ message: String, parameters: [String: AnyHashable]?)
}

public extension PACECloudSDKDelegate {
    func reportBreadcrumbs(_ message: String, parameters: [String: AnyHashable]?) {}
    func reportError(_ message: String, parameters: [String: AnyHashable]?) {}
}
