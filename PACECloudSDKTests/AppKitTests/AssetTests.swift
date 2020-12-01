//
//  AssetTests.swift
//  AppKitTests
//
//  Created by PACE Telematics GmbH.
//

import XCTest
@testable import PACECloudSDK

class AssetTests: XCTestCase {
    func testLoadColorsDarkTheme() {
        AppKit.shared.theme = .dark

        XCTAssertEqual(AppStyle.backgroundColor1, UIColor(red: 18.0 / 255.0, green: 19.0 / 255.0, blue: 19.0 / 255.0, alpha: 1.0))
        XCTAssertEqual(AppStyle.backgroundColor3, UIColor(red: 35.0 / 255.0, green: 39.0 / 255.0, blue: 41.0 / 255.0, alpha: 1.0))
        XCTAssertEqual(AppStyle.textColor1, UIColor.white)
        XCTAssertEqual(AppStyle.textColor2, UIColor.white)
    }

    func testLoadColorsLightTheme() {
        AppKit.shared.theme = .light

        XCTAssertEqual(AppStyle.textColor1, UIColor(red: 18.0 / 255.0, green: 19.0 / 255.0, blue: 19.0 / 255.0, alpha: 1.0))
        XCTAssertEqual(AppStyle.textColor2, UIColor(red: 117.0 / 255.0, green: 132.0 / 255.0, blue: 140.0 / 255.0, alpha: 1.0))
    }

    func testLoadImages() {
        XCTAssertEqual(AppStyle.noNetworkIcon, UIImage(named: "no_internet_connection", in: Bundle.paceCloudSDK, compatibleWith: nil))
        XCTAssertEqual(AppStyle.roundCloseIcon, UIImage(named: "round_close_icon", in: Bundle.paceCloudSDK, compatibleWith: nil))
        XCTAssertEqual(AppStyle.pacePayLogoSmall, UIImage(named: "pace_pay_small", in: Bundle.paceCloudSDK, compatibleWith: nil))
        XCTAssertEqual(AppStyle.iconNotificationError, UIImage(named: "notification_error", in: Bundle.paceCloudSDK, compatibleWith: nil))
        XCTAssertEqual(AppStyle.webBackIcon, UIImage(named: "webBackIcon", in: Bundle.paceCloudSDK, compatibleWith: nil))
        XCTAssertEqual(AppStyle.webForwardIcon, UIImage(named: "webForwardIcon", in: Bundle.paceCloudSDK, compatibleWith: nil))
        XCTAssertEqual(AppStyle.lockIcon, UIImage(named: "lock", in: Bundle.paceCloudSDK, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate))
    }

    func testLoadFonts() {
        AppStyle.loadAllFonts()
        let fontSize: CGFloat = 10
        XCTAssertEqual(AppStyle.lightFont(ofSize: fontSize), UIFont(name: "SFUIDisplay-Light", size: fontSize))
        XCTAssertEqual(AppStyle.regularFont(ofSize: fontSize), UIFont(name: "SFUIDisplay-Regular", size: fontSize))
        XCTAssertEqual(AppStyle.mediumFont(ofSize: fontSize), UIFont(name: "SFUIDisplay-Medium", size: fontSize))
    }
}
