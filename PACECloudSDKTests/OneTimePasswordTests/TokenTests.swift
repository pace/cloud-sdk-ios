//
//  TokenTests.swift
//  PACECloudSDKTests
//
//  Created by PACE Telematics GmbH.
//

@testable import PACECloudSDK
import XCTest

class TokenTests: XCTestCase {
    let secretData = "12345678901234567890".data(using: String.Encoding.ascii)!
    let otherSecretData = "09876543210987654321".data(using: String.Encoding.ascii)!

    func testInit() {
        // Create a token
        let name = "Test Name"
        let issuer = "Test Issuer"
        guard let generator = OneTimePassword.Generator(
            factor: .counter(111),
            secret: secretData,
            algorithm: .sha1,
            digits: 6
        ) else {
            XCTFail("Failed to construct Generator.")
            return
        }

        let token = OneTimePassword.Token(
            name: name,
            issuer: issuer,
            generator: generator
        )

        XCTAssertEqual(token.name, name)
        XCTAssertEqual(token.issuer, issuer)
        XCTAssertEqual(token.generator, generator)

        // Create another token
        let otherName = "Other Test Name"
        let otherIssuer = "Other Test Issuer"
        guard let otherGenerator = OneTimePassword.Generator(
            factor: .timer(period: 123),
            secret: otherSecretData,
            algorithm: .sha512,
            digits: 8
        ) else {
            XCTFail("Failed to construct Generator.")
            return
        }

        let otherToken = OneTimePassword.Token(
            name: otherName,
            issuer: otherIssuer,
            generator: otherGenerator
        )

        XCTAssertEqual(otherToken.name, otherName)
        XCTAssertEqual(otherToken.issuer, otherIssuer)
        XCTAssertEqual(otherToken.generator, otherGenerator)

        // Ensure the tokens are different
        XCTAssertNotEqual(token.name, otherToken.name)
        XCTAssertNotEqual(token.issuer, otherToken.issuer)
        XCTAssertNotEqual(token.generator, otherToken.generator)
    }

    func testDefaults() {
        guard let generator = OneTimePassword.Generator(
            factor: .counter(0),
            secret: Data(),
            algorithm: .sha1,
            digits: 6
        ) else {
            XCTFail("Failed to construct Generator.")
            return
        }
        let name = "Test Name"
        let issuer = "Test Issuer"

        let tokenWithDefaultName = OneTimePassword.Token(issuer: issuer, generator: generator)
        XCTAssertEqual(tokenWithDefaultName.name, "")
        XCTAssertEqual(tokenWithDefaultName.issuer, issuer)

        let tokenWithDefaultIssuer = OneTimePassword.Token(name: name, generator: generator)
        XCTAssertEqual(tokenWithDefaultIssuer.name, name)
        XCTAssertEqual(tokenWithDefaultIssuer.issuer, "")

        let tokenWithAllDefaults = OneTimePassword.Token(generator: generator)
        XCTAssertEqual(tokenWithAllDefaults.name, "")
        XCTAssertEqual(tokenWithAllDefaults.issuer, "")
    }

    func testCurrentPassword() {
        guard let timerGenerator = OneTimePassword.Generator(
            factor: .timer(period: 30),
            secret: secretData,
            algorithm: .sha1,
            digits: 6
        ) else {
            XCTFail("Failed to construct Generator.")
            return
        }
        let timerToken = OneTimePassword.Token(generator: timerGenerator)

        do {
            let password = try timerToken.generator.password(at: Date())
            XCTAssertEqual(timerToken.currentPassword, password)

            let oldPassword = try timerToken.generator.password(at: Date(timeIntervalSince1970: 0))
            XCTAssertNotEqual(timerToken.currentPassword, oldPassword)
        } catch {
            XCTFail("Failed to generate password with error: \(error)")
            return
        }

        guard let counterGenerator = OneTimePassword.Generator(
            factor: .counter(12345),
            secret: otherSecretData,
            algorithm: .sha1,
            digits: 6
        ) else {
            XCTFail("Failed to construct Generator.")
            return
        }
        let counterToken = OneTimePassword.Token(generator: counterGenerator)

        do {
            let password = try counterToken.generator.password(at: Date())
            XCTAssertEqual(counterToken.currentPassword, password)

            let oldPassword = try counterToken.generator.password(at: Date(timeIntervalSince1970: 0))
            XCTAssertEqual(counterToken.currentPassword, oldPassword)
        } catch {
            XCTFail("Failed to generate password with error: \(error)")
            return
        }
    }

    func testUpdatedToken() {
        guard let timerGenerator = OneTimePassword.Generator(
            factor: .timer(period: 30),
            secret: secretData,
            algorithm: .sha1,
            digits: 6
        ) else {
            XCTFail("Failed to construct Generator.")
            return
        }

        let timerToken = OneTimePassword.Token(generator: timerGenerator)

        let count: UInt64 = 12345
        guard let counterGenerator = OneTimePassword.Generator(
            factor: .counter(count),
            secret: otherSecretData,
            algorithm: .sha1,
            digits: 6
        ) else {
            XCTFail("Failed to construct Generator.")
            return
        }
    }
}
