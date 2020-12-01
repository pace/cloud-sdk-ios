//
//  MimeTypeTests.swift
//  PACECloudSDKTests
//
//  Created by PACE Telematics GmbH.
//

import XCTest
@testable import PACECloudSDK

class MimeTypeTests: XCTestCase {

    // MARK: - getExtension

    func testGetExtension_mimeTypeNotInList_returnNil() {
        XCTAssertNil(MimeTypes.getExtension(for: "not/available"))
    }

    func testGetExtension_mimeTypeInList_returnExtension() {
        XCTAssertEqual(MimeTypes.getExtension(for: "text/css"), "css")
        XCTAssertEqual(MimeTypes.getExtension(for: "application/pdf"), "pdf")
    }

    // MARK: - value

    func testValue_noExtension_returnHtml() {
        let mimeType = MimeTypes(path: "")
        XCTAssertEqual(mimeType.value, "text/html")
    }

    func testValue_extensionHasNoMimeType_returnHtml() {
        let mimeType = MimeTypes(path: "file.notavailable")
        XCTAssertEqual(mimeType.value, "text/html")
    }

    func testValue_extensionHasMimeType_returnMimeType() {
        XCTAssertEqual(MimeTypes(path: "file.html").value, "text/html")
        XCTAssertEqual(MimeTypes(path: "file.css").value, "text/css")
        XCTAssertEqual(MimeTypes(path: "file.pdf").value, "application/pdf")
    }
}
