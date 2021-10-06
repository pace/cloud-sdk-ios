//
//  AppStyle+Fonts.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import UIKit

extension AppStyle {
    static func lightFont(ofSize size: CGFloat) -> UIFont {
        UIFont.systemFont(ofSize: size, weight: .light)
    }

    static func regularFont(ofSize size: CGFloat) -> UIFont {
        UIFont.systemFont(ofSize: size, weight: .regular)
    }

    static func mediumFont(ofSize size: CGFloat) -> UIFont? {
        UIFont.systemFont(ofSize: size, weight: .medium)
    }
}
