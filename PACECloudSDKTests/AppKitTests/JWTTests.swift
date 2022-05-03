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

    func testExpiredToken() {
        // Expiry date: Tue May 03 2022 09:30:00 GMT+0000
        let expiredToken = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWUsImp0aSI6ImI2NDk1YWUyLWE1YjAtNGQyYi04N2Y5LThhMDgzNWIwN2JmMyIsImlhdCI6MTYwNTEwMjMwOSwiZXhwIjoxNjUxNTcwMjAwfQ.Kc0AS546mgkP9yKdKpMR9KYVZkXJhNA2xGR5jYMq_FY"
        let tokenValidator = IDKit.TokenValidator(accessToken: expiredToken, dateTimeProvider: MockDateTimeProvider())
        XCTAssertFalse(tokenValidator.isTokenValid())
    }

    func testTokenNotValidInNext10Minutes() {
        // Tue May 03 2022 09:45:00 GMT+0000
        let expiredToken = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWUsImp0aSI6ImI2NDk1YWUyLWE1YjAtNGQyYi04N2Y5LThhMDgzNWIwN2JmMyIsImlhdCI6MTYwNTEwMjMwOSwiZXhwIjoxNjUxNTcxMTAwfQ.1Yj-bPHgMAK8GIMeX63z_tu94yKbREieSKlh_Ql-A0w"
        let tokenValidator = IDKit.TokenValidator(accessToken: expiredToken, dateTimeProvider: MockDateTimeProvider())
        XCTAssertFalse(tokenValidator.isTokenValid())
    }

    func testTokenValidInNext10Minutes() {
        // Tue May 03 2022 10:00:00 GMT+0000
        let validToken = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWUsImp0aSI6ImI2NDk1YWUyLWE1YjAtNGQyYi04N2Y5LThhMDgzNWIwN2JmMyIsImlhdCI6MTYwNTEwMjMwOSwiZXhwIjoxNjUxNTcyMDAwfQ.Uu0Qn20Zcmk14zL1RkTjNw5ZbqnzuwzJ98StVxXLpMU"
        let tokenValidator = IDKit.TokenValidator(accessToken: validToken, dateTimeProvider: MockDateTimeProvider())
        XCTAssertTrue(tokenValidator.isTokenValid())
    }
}

extension JWTTests {
    class MockDateTimeProvider: DateTimeProvider {
        var currentDate: Date {
            Date(timeIntervalSince1970: 1651570800) // Tue May 03 2022 09:40:00 GMT+0000
        }
    }
}
