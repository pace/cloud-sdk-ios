//
//  Base32Tests.swift
//  PACECloudSDKTests
//
//  Created by PACE Telematics GmbH.
//

@testable import PACECloudSDK
import XCTest

class Base32Tests: XCTestCase {
    let vectors: [(String,String,String)] = [
        ("", "", ""),
        ("f", "MY======", "CO======"),
        ("fo", "MZXQ====", "CPNG===="),
        ("foo", "MZXW6===", "CPNMU==="),
        ("foob", "MZXW6YQ=", "CPNMUOG="),
        ("fooba", "MZXW6YTB", "CPNMUOJ1"),
        ("foobar", "MZXW6YTBOI======", "CPNMUOJ1E8======"),
    ]

    func testRFC4648Base32Decode() {
        let convertedVectors = self.vectors.map {($0.dataUsingUTF8StringEncoding, $1, $2)}
        self.measure{
            for _ in 0...100 {
                for (expect, test, _) in convertedVectors {
                    let result = test.base32DecodedData
                    XCTAssertEqual(result!, expect, "base32Decode for \(test)")
                }
            }
        }
    }

    func testBase32DecodeStringAcceptableLengthPatterns() {
        let strippedVectors = vectors.map {
            (
                $0.dataUsingUTF8StringEncoding,
                $1.replacingOccurrences(of: "=", with:""),
                $2.replacingOccurrences(of: "=", with:"")
            )
        }

        for (expect, test, _) in strippedVectors {
            let result = test.base32DecodedData
            XCTAssertEqual(result!, expect, "base32Decode for \(test)")
        }

        let invalidVectorWithPaddings: [(String,String)] = [
            ("M=======", "C======="),
            ("MYZ=====", "COZ====="),
            ("MZXW6Z==", "CPNMUZ=="),
            ("MZXW6YTBO=======", "CPNMUOJ1E======="),
        ]

        for (test, _) in invalidVectorWithPaddings {
            let result = test.base32DecodedData
            XCTAssertNil(result, "base32Decode for \(test)")
        }

        let invalidVectorWithoutPaddings = invalidVectorWithPaddings.map {
            (
                $0.replacingOccurrences(of: "=", with:""),
                $1.replacingOccurrences(of: "=", with:"")
            )
        }

        for (test, _) in invalidVectorWithoutPaddings {
            let result = test.base32DecodedData
            XCTAssertNil(result, "base32Decode for \(test)")
        }
    }

    func testDataUsingUTF8StringEncoding() {
        let string = "0112233445566778899AABBCCDDEEFFaabbccddeefff"
        XCTAssertEqual(string.dataUsingUTF8StringEncoding, string.data(using: .utf8, allowLossyConversion: false)!)
    }
}
