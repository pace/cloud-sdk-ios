//
//  DrawerViewModel.swift
//  PACECloudSDKExample
//
//  Created by PACE Telematics GmbH.
//

import Foundation
import PACECloudSDK
import SwiftUI

protocol DrawerViewModel: ObservableObject {
    var drawers: [AppKit.AppDrawer] { get }
    var isLoading: Bool { get }
    var didFailDrawers: Bool { get }
    func requestAppDrawers()
}
