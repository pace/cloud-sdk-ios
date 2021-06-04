//
//  IconSelectorTests.swift
//  PACECloudSDKTests
//
//  Created by PACE Telematics GmbH.
//

@testable import PACECloudSDK
import XCTest

class IconSelectorTests: XCTestCase {
    // Reference size is 64x64

    func testOneIcon() {
        let appIcon = AppIcon(source: "source", sizes: "32x32", type: "png")
        let selectedIcon = IconSelector.chooseSuitableDrawerIcon(in: [appIcon])
        XCTAssertNotNil(selectedIcon)
        XCTAssertEqual(appIcon.sizes, selectedIcon?.sizes)
    }

    func testNoIcon() {
        let selectedIcon = IconSelector.chooseSuitableDrawerIcon(in: [])
        XCTAssertNil(selectedIcon)
    }

    func testOneIconNoSize() {
        let appIcon = AppIcon(source: "source", sizes: "", type: "png")
        let selectedIcon = IconSelector.chooseSuitableDrawerIcon(in: [appIcon])
        XCTAssertNil(selectedIcon)
    }

    func testMultipleIcons() {
        let appIcon1 = AppIcon(source: "source", sizes: "16x12", type: "png")
        let appIcon2 = AppIcon(source: "source", sizes: "74x68", type: "png")
        let selectedIcon = IconSelector.chooseSuitableDrawerIcon(in: [appIcon1, appIcon2])
        XCTAssertNotNil(selectedIcon)
        XCTAssertEqual(appIcon2.sizes, selectedIcon?.sizes)
    }

    func testMultipleIconsAvailableNoSize() {
        let appIcon1 = AppIcon(source: "source", sizes: "", type: "png")
        let appIcon2 = AppIcon(source: "source", sizes: "", type: "png")
        let selectedIcon = IconSelector.chooseSuitableDrawerIcon(in: [appIcon1, appIcon2])
        XCTAssertNil(selectedIcon)
    }

    func testMultipleIconsMultipleSizes() {
        let appIcon1 = AppIcon(source: "source", sizes: "12x12 16x21 65x63", type: "png")
        let appIcon2 = AppIcon(source: "source", sizes: "120x120 128x64", type: "png")
        let appIcon3 = AppIcon(source: "source", sizes: "45x67 32x32", type: "png")
        let appIcon4 = AppIcon(source: "source", sizes: "asdf", type: "png")
        let selectedIcon = IconSelector.chooseSuitableDrawerIcon(in: [appIcon1, appIcon2, appIcon3, appIcon4])
        XCTAssertNotNil(selectedIcon)
        XCTAssertEqual(appIcon1.sizes, selectedIcon?.sizes)
    }
}
