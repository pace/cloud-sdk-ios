//
//  Notification+Extension.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

// MARK: - AppKit
extension Notification.Name {
    static let appEventOccured = Notification.Name("appEventOccured")
}

// MARK: - POIKit
public extension Notification.Name {
    static let didUpdateLocation = Notification.Name("didUpdateLocation")
}
