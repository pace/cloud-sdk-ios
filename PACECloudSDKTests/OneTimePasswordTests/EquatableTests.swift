//
//  EquatableTests.swift
//  PACECloudSDKTests
//
//  Created by PACE Telematics GmbH.
//

@testable import PACECloudSDK
import XCTest

class EquatableTests: XCTestCase {
    func testFactorEquality() {
        let smallCounter = OneTimePassword.Generator.Factor.counter(30)
        let bigCounter = OneTimePassword.Generator.Factor.counter(60)
        let shortTimer = OneTimePassword.Generator.Factor.timer(period: 30)
        let longTimer = OneTimePassword.Generator.Factor.timer(period: 60)

        XCTAssertEqual(smallCounter, smallCounter)
        XCTAssertEqual(bigCounter, bigCounter)
        XCTAssertNotEqual(smallCounter, bigCounter)
        XCTAssertNotEqual(bigCounter, smallCounter)

        XCTAssertEqual(shortTimer, shortTimer)
        XCTAssertEqual(longTimer, longTimer)
        XCTAssertNotEqual(shortTimer, longTimer)
        XCTAssertNotEqual(longTimer, shortTimer)

        XCTAssertNotEqual(smallCounter, shortTimer)
        XCTAssertNotEqual(smallCounter, longTimer)
        XCTAssertNotEqual(bigCounter, shortTimer)
        XCTAssertNotEqual(bigCounter, longTimer)

        XCTAssertNotEqual(shortTimer, smallCounter)
        XCTAssertNotEqual(shortTimer, bigCounter)
        XCTAssertNotEqual(longTimer, smallCounter)
        XCTAssertNotEqual(longTimer, bigCounter)
    }

    func testGeneratorEquality() {
        let generator = OneTimePassword.Generator(factor: .counter(0), secret: Data(), algorithm: .sha1, digits: 6)
        let badData = "0".data(using: String.Encoding.utf8)!

        XCTAssert(generator == OneTimePassword.Generator(factor: .counter(0), secret: Data(), algorithm: .sha1, digits: 6))
        XCTAssert(generator != OneTimePassword.Generator(factor: .counter(1), secret: Data(), algorithm: .sha1, digits: 6))
        XCTAssert(generator != OneTimePassword.Generator(factor: .counter(0), secret: badData, algorithm: .sha1, digits: 6))
        XCTAssert(generator != OneTimePassword.Generator(factor: .counter(0), secret: Data(), algorithm: .sha256, digits: 6))
        XCTAssert(generator != OneTimePassword.Generator(factor: .counter(0), secret: Data(), algorithm: .sha1, digits: 8))
    }

    func testTokenEquality() {
        guard let generator = OneTimePassword.Generator(factor: .counter(0), secret: Data(), algorithm: .sha1, digits: 6),
              let otherGenerator = OneTimePassword.Generator(factor: .counter(1), secret: Data(), algorithm: .sha512, digits: 8) else {
            XCTFail("Failed to construct Generator.")
            return
        }

        let token = OneTimePassword.Token(name: "Name", issuer: "Issuer", generator: generator)

        XCTAssertEqual(token, OneTimePassword.Token(name: "Name", issuer: "Issuer", generator: generator))
        XCTAssertNotEqual(token, OneTimePassword.Token(name: "", issuer: "Issuer", generator: generator))
        XCTAssertNotEqual(token, OneTimePassword.Token(name: "Name", issuer: "", generator: generator))
        XCTAssertNotEqual(token, OneTimePassword.Token(name: "Name", issuer: "Issuer", generator: otherGenerator))
    }
}
