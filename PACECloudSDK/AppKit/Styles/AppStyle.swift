//
//  AppStyle.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import UIKit

struct AppStyle {
    static var leftAndRightScreenPadding: CGFloat {
        return 15
    }

    static var buttonScreenPadding: CGFloat {
        return 20
    }

    static let drawerSize: CGFloat = 64
    static let drawerMargin: CGFloat = 16
    static let drawerMaxWidth = UIScreen.main.bounds.width - drawerMargin

    static let iconSize: CGFloat = 40
    static let closeButtonSize: CGFloat = 48

    // Animations
    static let animationDuration: TimeInterval = 0.6
    static let damping: CGFloat = 0.7
    static let springVelocity: CGFloat = 0.5
}
