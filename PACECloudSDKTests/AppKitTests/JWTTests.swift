//
//  JWTTests.swift
//  PACECloudSDKTests
//
//  Created by PACE Telematics GmbH.
//

import XCTest
@testable import PACECloudSDK

class JWTTests: XCTestCase {
    private let validToken = """
    eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWUsImp0aSI6ImI2NDk1YWUyLWE1YjAtNGQyYi04N2Y5LThhMDgzNWIwN2JmMyIsImlhdCI6MTYwNTEwMjMwOSwiZXhwIjoxNjA1MTA1OTA5fQ.BXnkfB5aLcclqKGHpjsQxMYEs5DBN20BQ6FblMkZIIs
    """

    private let invalidToken = """
    eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWUsImp0aSI6ImI2NDk1YWUyLWE1YjAtNGQyYi04N2Y5LThhMDgzNWIwN2JmMyIsImlhdCI6MTYwNTEwMjMwOSwiZXhwIjoxNjA1MTA1OTA5fQ.BXnkfB5aLcclqKGHpjsQxMYEs5DBN20BQ6FblMkZIIs
    """

    func testValidJWTToken() {
        do {
            let _ = try JWTToken(jwt: validToken)
        } catch {
            XCTFail()
        }
    }

    func testInvalidJWTToken() {
        do {
            let _ = try JWTToken(jwt: invalidToken)
            XCTFail()
        } catch {}
    }

    func testRetrieveExpiresAt() {
        do {
            let token = try JWTToken(jwt: validToken)
            let date = token.expiresAt
            XCTAssertNotNil(date)
            XCTAssertEqual(date, Date(timeIntervalSince1970: 1605105909))
        } catch {
            XCTFail()
        }
    }
}
