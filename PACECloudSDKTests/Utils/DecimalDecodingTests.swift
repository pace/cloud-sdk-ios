//
//  DecimalDecodingTests.swift
//  PACECloudSDKTests
//
//  Created by PACE Telematics GmbH.
//

import XCTest
@testable import PACECloudSDK

class DecimalDecodingTests: XCTestCase {
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    func testDecimalDecodingSuccess() {
        let values: [Double] = [7.20, 64.55, 101.01, 1.20, 0.95, 29.29]

        values.forEach {
            guard let decodedValue = decode(decimalValue: $0) else {
                return
            }

            XCTAssertLessThanOrEqual(decodedValue.significantFractionalDecimalDigits, 2)
            XCTAssertTrue(values.contains($0))
        }
    }

    func testDecimalDecodingError() {
        let values: [Double] = [68.32, 90.15]

        values.forEach {
            guard let decodedValue = decode(decimalValue: $0) else {
                return
            }

            XCTAssertGreaterThan(decodedValue.significantFractionalDecimalDigits, 2)
        }
    }

    func testCustomDecoding() {
        let jsonString =
            """
            {
                "amount1": 68.32,
                "amount2": 90.15,
                "amount3": 7.20,
                "amount4": 64.55,
                "amount5": 101.01,
                "amount6": 1.20,
                "amount7": 0.95,
                "amount8": 29.29
            }
            """

        let data = jsonString.data(using: .utf8)!
        let result = try! JSONDecoder().decode(Response.self, from: data)

        [result.amount1, result.amount2, result.amount3, result.amount4, result.amount5, result.amount6, result.amount7, result.amount8].forEach {
            XCTAssertLessThanOrEqual($0.significantFractionalDecimalDigits, 2)
        }

        XCTAssertEqual("\(result.amount1)", "68.32")
        XCTAssertEqual("\(result.amount2)", "90.15")
        XCTAssertEqual("\(result.amount3)", "7.2")
        XCTAssertEqual("\(result.amount4)", "64.55")
        XCTAssertEqual("\(result.amount5)", "101.01")
        XCTAssertEqual("\(result.amount6)", "1.2")
        XCTAssertEqual("\(result.amount7)", "0.95")
        XCTAssertEqual("\(result.amount8)", "29.29")
    }
}

// MARK: - Default decoder
extension DecimalDecodingTests {
    func decode(decimalValue: Double) -> Decimal? {
        do {
            let data = try encoder.encode(decimalValue)
            let decodedDecimal = try decoder.decode(Decimal.self, from: data)
            return decodedDecimal
        } catch {
            return nil
        }
    }


}

// MARK: - Custom decoder
extension DecimalDecodingTests {
    struct Response: Codable {
        let amount1, amount2, amount3, amount4, amount5, amount6, amount7, amount8: Decimal
    }
}

extension DecimalDecodingTests.Response {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.amount1 = try container.decode(Double.self, forKey: .amount1).decimal ?? .zero
        self.amount2 = try container.decode(Double.self, forKey: .amount2).decimal ?? .zero
        self.amount3 = try container.decode(Double.self, forKey: .amount3).decimal ?? .zero
        self.amount4 = try container.decode(Double.self, forKey: .amount4).decimal ?? .zero
        self.amount5 = try container.decode(Double.self, forKey: .amount5).decimal ?? .zero
        self.amount6 = try container.decode(Double.self, forKey: .amount6).decimal ?? .zero
        self.amount7 = try container.decode(Double.self, forKey: .amount7).decimal ?? .zero
        self.amount8 = try container.decode(Double.self, forKey: .amount8).decimal ?? .zero
    }
}
