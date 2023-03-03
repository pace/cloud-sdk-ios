//
//  Base32+String.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

extension String {
    var base32DecodedData: Data? {
        Base32.base32Decoded(self)
    }

    var dataUsingUTF8StringEncoding: Data {
        utf8CString.withUnsafeBufferPointer {
            Data($0.dropLast().map { UInt8.init($0) })
        }
    }
}
