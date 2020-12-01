//
//  AppStyle+Colors.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import UIKit

extension AppStyle {
    static var whiteColor: UIColor {
        return UIColor.white
    }

    static var orangeColor: UIColor {
        return UIColor(red: 255.0 / 255.0, green: 150.0 / 255.0, blue: 1.0 / 255.0, alpha: 1.0)
    }

    static var blueColor: UIColor {
        return UIColor(red: 0.0 / 255.0, green: 204.0 / 255.0, blue: 240.0 / 255.0, alpha: 1.0)
    }

    static var gray1Color: UIColor {
        return UIColor(red: 18.0 / 255.0, green: 19.0 / 255.0, blue: 19.0 / 255.0, alpha: 1.0)
    }

    static var gray2Color: UIColor {
        return UIColor(red: 27.0 / 255.0, green: 29.0 / 255.0, blue: 30.0 / 255.0, alpha: 1.0)
    }

    static var gray3Color: UIColor {
        return UIColor(red: 35.0 / 255.0, green: 39.0 / 255.0, blue: 41.0 / 255.0, alpha: 1.0)
    }

    static var gray4Color: UIColor {
        return UIColor(red: 46.0 / 255.0, green: 54.0 / 255.0, blue: 58.0 / 255.0, alpha: 1.0)
    }

    static var gray6Color: UIColor {
        return UIColor(red: 117.0 / 255.0, green: 132.0 / 255.0, blue: 140.0 / 255.0, alpha: 1.0)
    }

    static var darkColor: UIColor {
        return UIColor(red: 35 / 255.0, green: 39 / 255.0, blue: 41 / 255.0, alpha: 1.0)
    }

    static var lightColor: UIColor {
        return whiteColor
    }

    static var backgroundColor1: UIColor {
        return AppKit.shared.theme.isDarkTheme ? gray1Color : .white
    }

    static var backgroundColor3: UIColor {
        return AppKit.shared.theme.isDarkTheme ? gray3Color : .white
    }

    static var textColor1: UIColor {
        return AppKit.shared.theme.isDarkTheme ? whiteColor : gray1Color
    }

    static var textColor2: UIColor {
        return AppKit.shared.theme.isDarkTheme ? whiteColor : gray6Color
    }
}
