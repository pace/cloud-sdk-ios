//
//  AppStyle+Fonts.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import UIKit

extension AppStyle {

    private static let lightFont = "SFUIDisplay-Light"
    private static let regularFont = "SFUIDisplay-Regular"
    private static let mediumFont = "SFUIDisplay-Medium"

    private static var fontSizeMultiplier: CGFloat {
        return 1.0
    }

    static func lightFont(ofSize size: CGFloat) -> UIFont? {
        return fontNamed(lightFont, size: size)
    }

    static func regularFont(ofSize size: CGFloat) -> UIFont? {
        return fontNamed(regularFont, size: size)
    }

    static func mediumFont(ofSize size: CGFloat) -> UIFont? {
        return fontNamed(mediumFont, size: size)
    }

    private static func fontNamed(_ name: String, size: CGFloat) -> UIFont? {
        let multipliedFontSize = round(size * fontSizeMultiplier)
        return UIFont(name: name, size: multipliedFontSize)
    }

    private static func loadFont(_ name: String) {
        guard
            let frameworkPath = Bundle.paceCloudSDK.path(forResource: name, ofType: "otf"),
            let fontData = NSData(contentsOfFile: frameworkPath),
            let dataProvider = CGDataProvider(data: fontData),
            let fontRef = CGFont(dataProvider)
        else {
            AppKitLogger.e("Failed to register font - register graphics font failed - this font may have already been registered in the main bundle.")
            return
        }

        var errorRef: Unmanaged<CFError>?

        if CTFontManagerRegisterGraphicsFont(fontRef, &errorRef) == false {
            AppKitLogger.e("Failed to register font - register graphics font failed - this font may have already been registered in the main bundle.")
        }
    }

    static func loadAllFonts() {
        [
            lightFont,
            regularFont,
            mediumFont
        ].forEach { loadFont($0) }
    }
}
