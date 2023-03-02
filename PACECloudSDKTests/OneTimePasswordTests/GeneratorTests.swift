//
//  GeneratorTests.swift
//  PACECloudSDKTests
//
//  Created by PACE Telematics GmbH.
//

@testable import PACECloudSDK
import XCTest

class GeneratorTests: XCTestCase {
    func testInit() {
        let factor = OneTimePassword.Generator.Factor.counter(111)
        let secret = "12345678901234567890".data(using: String.Encoding.ascii)!
        let algorithm = OneTimePassword.Generator.Algorithm.sha256
        let digits = 8

        let generator = OneTimePassword.Generator(
            factor: factor,
            secret: secret,
            algorithm: algorithm,
            digits: digits
        )

        XCTAssertEqual(generator?.factor, factor)
        XCTAssertEqual(generator?.secret, secret)
        XCTAssertEqual(generator?.algorithm, algorithm)
        XCTAssertEqual(generator?.digits, digits)

        let otherFactor = OneTimePassword.Generator.Factor.timer(period: 123)
        let otherSecret = "09876543210987654321".data(using: String.Encoding.ascii)!
        let otherAlgorithm = OneTimePassword.Generator.Algorithm.sha512
        let otherDigits = 7

        let otherGenerator = OneTimePassword.Generator(
            factor: otherFactor,
            secret: otherSecret,
            algorithm: otherAlgorithm,
            digits: otherDigits
        )

        XCTAssertEqual(otherGenerator?.factor, otherFactor)
        XCTAssertEqual(otherGenerator?.secret, otherSecret)
        XCTAssertEqual(otherGenerator?.algorithm, otherAlgorithm)
        XCTAssertEqual(otherGenerator?.digits, otherDigits)

        XCTAssertNotEqual(generator?.factor, otherGenerator?.factor)
        XCTAssertNotEqual(generator?.secret, otherGenerator?.secret)
        XCTAssertNotEqual(generator?.algorithm, otherGenerator?.algorithm)
        XCTAssertNotEqual(generator?.digits, otherGenerator?.digits)
    }

    func testCounter() {
        let factors: [(TimeInterval, TimeInterval, UInt64)] = [
            // swiftlint:disable comma
            (100,         30, 3),
            (10000,       30, 333),
            (1000000,     30, 33333),
            (100000000,   60, 1666666),
            (10000000000, 90, 111111111),
            // swiftlint:enable comma
        ]

        for (timeSinceEpoch, period, count) in factors {
            let time = Date(timeIntervalSince1970: timeSinceEpoch)
            let timer = OneTimePassword.Generator.Factor.timer(period: period)
            let counter = OneTimePassword.Generator.Factor.counter(count)
            let secret = "12345678901234567890".data(using: String.Encoding.ascii)!
            let hotp = OneTimePassword.Generator(factor: counter, secret: secret, algorithm: .sha1, digits: 6)
                .flatMap { try? $0.password(at: time) }
            let totp = OneTimePassword.Generator(factor: timer, secret: secret, algorithm: .sha1, digits: 6)
                .flatMap { try? $0.password(at: time) }
            XCTAssertEqual(hotp, totp,
                           "TOTP with \(timer) should match HOTP with counter \(counter) at time \(time).")
        }
    }

    func testValidation() {
        let digitTests: [(Int, Bool)] = [
            (-6, false),
            (0, false),
            (1, false),
            (5, false),
            (6, true),
            (7, true),
            (8, true),
            (9, false),
            (10, false),
        ]

        let periodTests: [(TimeInterval, Bool)] = [
            (-30, false),
            (0, false),
            (1, true),
            (30, true),
            (300, true),
            (301, true),
        ]

        for (digits, digitsAreValid) in digitTests {
            let generator = OneTimePassword.Generator(
                factor: .counter(0),
                secret: Data(),
                algorithm: .sha1,
                digits: digits
            )

            let generatorIsValid = digitsAreValid
            if generatorIsValid {
                XCTAssertNotNil(generator)
            } else {
                XCTAssertNil(generator)
            }

            for (period, periodIsValid) in periodTests {
                let generator = OneTimePassword.Generator(
                    factor: .timer(period: period),
                    secret: Data(),
                    algorithm: .sha1,
                    digits: digits
                )

                let generatorIsValid = digitsAreValid && periodIsValid
                if generatorIsValid {
                    XCTAssertNotNil(generator)
                } else {
                    XCTAssertNil(generator)
                }
            }
        }
    }

    func testPasswordAtInvalidTime() {
        guard let generator = OneTimePassword.Generator(
            factor: .timer(period: 30),
            secret: Data(),
            algorithm: .sha1,
            digits: 6
        ) else {
            XCTFail("Failed to initialize a Generator.")
            return
        }

        let badTime = Date(timeIntervalSince1970: -100)
        do {
            _ = try generator.password(at: badTime)
        } catch OneTimePassword.Generator.GeneratorError.invalidTime {
            // This is the expected type of error
            return
        } catch {
            XCTFail("passwordAtTime(\(badTime)) threw an unexpected type of error: \(error))")
            return
        }
        XCTFail("passwordAtTime(\(badTime)) should throw an error)")
    }

    func testPasswordWithInvalidPeriod() {
        let generator = OneTimePassword.Generator(factor: .timer(period: 0), secret: Data(), algorithm: .sha1, digits: 8)
        XCTAssertNil(generator)
    }

    func testPasswordWithInvalidDigits() {
        let generator = OneTimePassword.Generator(factor: .timer(period: 30), secret: Data(), algorithm: .sha1, digits: 3)
        XCTAssertNil(generator)
    }

    func testHOTPRFCValues() {
        let secret = "12345678901234567890".data(using: String.Encoding.ascii)!
        let expectedValues: [UInt64: String] = [
            0: "755224",
            1: "287082",
            2: "359152",
            3: "969429",
            4: "338314",
            5: "254676",
            6: "287922",
            7: "162583",
            8: "399871",
            9: "520489",
        ]
        for (counter, expectedPassword) in expectedValues {
            let generator = OneTimePassword.Generator(factor: .counter(counter), secret: secret, algorithm: .sha1, digits: 6)
            let time = Date(timeIntervalSince1970: 0)
            let password = generator.flatMap { try? $0.password(at: time) }
            XCTAssertEqual(password, expectedPassword,
                           "The generator did not produce the expected OTP.")
        }
    }

    func testTOTPRFCValues() {
        let secretKeys: [OneTimePassword.Generator.Algorithm: String] = [
            .sha1:   "12345678901234567890",
            .sha256: "12345678901234567890123456789012",
            .sha512: "1234567890123456789012345678901234567890123456789012345678901234",
        ]

        let timesSinceEpoch: [TimeInterval] = [59, 1111111109, 1111111111, 1234567890, 2000000000, 20000000000]

        let expectedValues: [OneTimePassword.Generator.Algorithm: [String]] = [
            .sha1:   ["94287082", "07081804", "14050471", "89005924", "69279037", "65353130"],
            .sha256: ["46119246", "68084774", "67062674", "91819424", "90698825", "77737706"],
            .sha512: ["90693936", "25091201", "99943326", "93441116", "38618901", "47863826"],
        ]

        for (algorithm, secretKey) in secretKeys {
            let secret = secretKey.data(using: String.Encoding.ascii)!
            let generator = OneTimePassword.Generator(factor: .timer(period: 30), secret: secret, algorithm: algorithm, digits: 8)

            for (timeSinceEpoch, expectedPassword) in zip(timesSinceEpoch, expectedValues[algorithm]!) {
                let time = Date(timeIntervalSince1970: timeSinceEpoch)
                let password = generator.flatMap { try? $0.password(at: time) }
                XCTAssertEqual(password, expectedPassword,
                               "Incorrect result for \(algorithm) at \(timeSinceEpoch)")
            }
        }
    }

    func testTOTPGoogleValues() {
        let secret = "12345678901234567890".data(using: String.Encoding.ascii)!
        let timesSinceEpoch: [TimeInterval] = [1111111111, 1234567890, 2000000000]

        let expectedValues: [OneTimePassword.Generator.Algorithm: [String]] = [
            .sha1:   ["050471", "005924", "279037"],
            .sha256: ["584430", "829826", "428693"],
            .sha512: ["380122", "671578", "464532"],
        ]

        for (algorithm, expectedPasswords) in expectedValues {
            let generator = OneTimePassword.Generator(factor: .timer(period: 30), secret: secret, algorithm: algorithm, digits: 6)
            for (timeSinceEpoch, expectedPassword) in zip(timesSinceEpoch, expectedPasswords) {
                let time = Date(timeIntervalSince1970: timeSinceEpoch)
                let password = generator.flatMap { try? $0.password(at: time) }
                XCTAssertEqual(password, expectedPassword,
                               "Incorrect result for \(algorithm) at \(timeSinceEpoch)")
            }
        }
    }
}
