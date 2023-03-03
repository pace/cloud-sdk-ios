//
//  Crypto.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import CommonCrypto
#if canImport(CryptoKit)
import CryptoKit
#endif
import Foundation

extension OneTimePassword {
    enum Crypto {
        static func hmac(algorithm: Generator.Algorithm, key: Data, data: Data) -> Data {
            #if canImport(CryptoKit)
            if #available(iOS 13.0, macOS 10.15, watchOS 6.0, *) {
                return cryptoKitHMAC(algorithm: algorithm, key: key, data: data)
            } else {
                return commonCryptoHMAC(algorithm: algorithm, key: key, data: data)
            }
            #else
            return commonCryptoHMAC(algorithm: algorithm, key: key, data: data)
            #endif
        }

        #if canImport(CryptoKit)
        @available(iOS 13.0, macOS 10.15, watchOS 6.0, *)
        private static func cryptoKitHMAC(algorithm: Generator.Algorithm, key: Data, data: Data) -> Data {
            let key = SymmetricKey(data: key)

            switch algorithm {
            case .sha1:
                return CryptoKit.HMAC<Insecure.SHA1>.authenticationCode(for: data, using: key).withUnsafeBytes { ptr in
                    createData(ptr, algorithm)
                }

            case .sha256:
                return CryptoKit.HMAC<SHA256>.authenticationCode(for: data, using: key).withUnsafeBytes { ptr in
                    createData(ptr, algorithm)
                }

            case .sha512:
                return CryptoKit.HMAC<SHA512>.authenticationCode(for: data, using: key).withUnsafeBytes { ptr in
                    createData(ptr, algorithm)
                }
            }
        }

        @available(iOS 13.0, macOS 10.15, watchOS 6.0, *)
        private static func createData(_ ptr: UnsafeRawBufferPointer, _ algorithm: Generator.Algorithm) -> Data {
            Data(bytes: ptr.baseAddress!, count: algorithm.hashLength) // swiftlint:disable:this force_unwrapping
        }
        #endif

        private static func commonCryptoHMAC(algorithm: Generator.Algorithm, key: Data, data: Data) -> Data {
            let (hashFunction, hashLength) = algorithm.hashInfo
            let macOut = UnsafeMutablePointer<UInt8>.allocate(capacity: hashLength)

            defer {
                macOut.deallocate()
            }

            key.withUnsafeBytes { keyBytes in
                data.withUnsafeBytes { dataBytes in
                    CCHmac(hashFunction, keyBytes.baseAddress, key.count, dataBytes.baseAddress, data.count, macOut)
                }
            }

            return Data(bytes: macOut, count: hashLength)
        }
    }
}

#if canImport(CryptoKit)
@available(iOS 13.0, macOS 10.15, watchOS 6.0, *)
private extension OneTimePassword.Generator.Algorithm {
    var hashLength: Int {
        switch self {
        case .sha1:
            return Insecure.SHA1.byteCount

        case .sha256:
            return SHA256.byteCount

        case .sha512:
            return SHA512.byteCount
        }
    }
}
#endif

private extension OneTimePassword.Generator.Algorithm {
    var hashInfo: (hashFunction: CCHmacAlgorithm, hashLength: Int) {
        switch self {
        case .sha1:
            return (CCHmacAlgorithm(kCCHmacAlgSHA1), Int(CC_SHA1_DIGEST_LENGTH))

        case .sha256:
            return (CCHmacAlgorithm(kCCHmacAlgSHA256), Int(CC_SHA256_DIGEST_LENGTH))

        case .sha512:
            return (CCHmacAlgorithm(kCCHmacAlgSHA512), Int(CC_SHA512_DIGEST_LENGTH))
        }
    }
}
