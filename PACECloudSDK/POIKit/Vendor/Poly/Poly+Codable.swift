//
//  Poly+Codable.swift
//  Poly
//
//  Created by Mathew Polzin on 1/12/19.
//

// MARK: - Generic Decoding

public struct PolyDecodeNoTypesMatchedError: Swift.Error, CustomDebugStringConvertible {

    public struct IndividualFailure: Swift.Error {
        public let type: Any.Type
        public let error: DecodingError
    }

    public let codingPath: [CodingKey]
    public let individualTypeFailures: [IndividualFailure]

    public var debugDescription: String {
        let codingPathString = codingPath
            .map { $0.intValue.map(String.init) ?? $0.stringValue }
            .joined(separator: "/")

        let failureStrings = individualTypeFailures.map {
            let type = $0.type
            let descriptiveError = $0.error as CustomDebugStringConvertible
            let error = descriptiveError.debugDescription
            return "\(String(describing: type)) could not be decoded because:\n\(error)"
        }.joined(separator: "\n\n")

        return
"""
Poly failed to decode any of its types at: "\(codingPathString)"

\(failureStrings)
"""
    }
}

internal typealias PolyTypeNotFound = PolyDecodeNoTypesMatchedError.IndividualFailure

func decode<Thing: Decodable>(_ type: Thing.Type, from container: SingleValueDecodingContainer) throws -> Result<Thing, PolyTypeNotFound> {
	let ret: Result<Thing, PolyTypeNotFound>
	do {
		ret = try .success(container.decode(Thing.self))
	} catch (let err as DecodingError) {
		ret = .failure(PolyTypeNotFound(type: type, error: err))
	} catch (let err) {
        ret = .failure(PolyTypeNotFound(
            type: type,
            error: DecodingError.typeMismatch(
                Thing.self,
                .init(
                    codingPath: container.codingPath,
                    debugDescription: String(describing: err),
                    underlyingError: err
                )
            )
        ))
	}
	return ret
}
