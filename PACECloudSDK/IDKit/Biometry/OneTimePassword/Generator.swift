//
//  Generator.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

extension OneTimePassword {
    struct Generator: Equatable {
        let factor: Factor
        let secret: Data
        let algorithm: Algorithm
        let digits: Int

        init?(factor: Factor, secret: Data, algorithm: Algorithm, digits: Int) {
            do {
                try Generator.validateFactor(factor)
                try Generator.validateDigits(digits)
            } catch {
                return nil
            }

            self.factor = factor
            self.secret = secret
            self.algorithm = algorithm
            self.digits = digits
        }

        func password(at time: Date) throws -> String {
            try Generator.validateDigits(digits)

            let counter = try factor.counterValue(at: time)
            // Ensure the counter value is big-endian
            var bigCounter = counter.bigEndian

            let counterData = Data(bytes: &bigCounter, count: MemoryLayout<UInt64>.size)
            let hash = OneTimePassword.Crypto.hmac(algorithm: algorithm, key: secret, data: counterData)

            var truncatedHash = hash.withUnsafeBytes { ptr -> UInt32 in
                // Use the last 4 bits of the hash as an offset (0 <= offset <= 15)
                let offset = ptr[hash.count - 1] & 0x0f

                // Take 4 bytes from the hash, starting at the given byte offset
                let truncatedHashPtr = ptr.baseAddress! + Int(offset) // swiftlint:disable:this force_unwrapping
                return truncatedHashPtr.bindMemory(to: UInt32.self, capacity: 1).pointee
            }

            // Ensure the four bytes taken from the hash match the current endian format
            truncatedHash = UInt32(bigEndian: truncatedHash)
            // Discard the most significant bit
            truncatedHash &= 0x7fffffff
            // Constrain to the right number of digits
            truncatedHash = truncatedHash % UInt32(pow(10, Float(digits)))

            // Pad the string representation with zeros, if necessary
            return String(truncatedHash).padded(with: "0", toLength: digits)
        }
    }
}

extension OneTimePassword.Generator {
    enum Factor: Equatable {
        case counter(UInt64)
        case timer(period: TimeInterval)

        func counterValue(at time: Date) throws -> UInt64 {
            switch self {
            case .counter(let counter):
                return counter

            case .timer(let period):
                let timeSinceEpoch = time.timeIntervalSince1970
                try OneTimePassword.Generator.validateTime(timeSinceEpoch)
                try OneTimePassword.Generator.validatePeriod(period)
                return UInt64(timeSinceEpoch / period)
            }
        }
    }

    enum Algorithm: Equatable {
        case sha1
        case sha256
        case sha512
    }

    enum GeneratorError: Error {
        case invalidTime
        case invalidPeriod
        case invalidDigits
    }
}

private extension OneTimePassword.Generator {
    // https://tools.ietf.org/html/rfc4226#section-5.3
    static func validateDigits(_ digits: Int) throws {
        let acceptableDigits = 6...8
        guard acceptableDigits.contains(digits) else { throw GeneratorError.invalidDigits }
    }

    static func validateFactor(_ factor: Factor) throws {
        switch factor {
        case .counter:
            return

        case .timer(let period):
            try validatePeriod(period)
        }
    }

    static func validatePeriod(_ period: TimeInterval) throws {
        guard period > 0 else { throw GeneratorError.invalidPeriod }
    }

    static func validateTime(_ timeSinceEpoch: TimeInterval) throws {
        guard timeSinceEpoch >= 0 else { throw GeneratorError.invalidTime }
    }
}

private extension String {
    func padded(with character: Character, toLength length: Int) -> String {
        let paddingCount = length - count

        guard paddingCount > 0 else { return self }

        let padding = String(repeating: String(character), count: paddingCount)
        return padding + self
    }
}
