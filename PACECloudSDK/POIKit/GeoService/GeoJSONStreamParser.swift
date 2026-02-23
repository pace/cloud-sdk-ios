//
//  GeoJSONStreamParser.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//
// Raw byte reference — ASCII values used throughout this file:
//
//   0x22  "   double quote       (string delimiter / key marker)
//   0x2C  ,   comma              (array element separator)
//   0x5B  [   left bracket       (array open)
//   0x5C  \   backslash          (escape character inside strings)
//   0x5D  ]   right bracket      (array close / end of features array)
//   0x7B  {   left brace         (object open / start of a feature)
//   0x7D  }   right brace        (object close / end of a feature)
//   0x09  \t  horizontal tab     } whitespace
//   0x0A  \n  newline            }   skipped while
//   0x0D  \r  carriage return    }   iterating the
//   0x20      space              }   features array
//
// "features" key as a byte sequence (including surrounding quotes):
//   0x22 0x66 0x65 0x61 0x74 0x75 0x72 0x65 0x73 0x22
//    "    f    e    a    t    u    r    e    s    "

import Foundation

enum GeoJSONStreamParser {
    // "features" key including surrounding quotes
    private static let featuresKey: [UInt8] = [0x22, 0x66, 0x65, 0x61, 0x74, 0x75, 0x72, 0x65, 0x73, 0x22]

    /// Parses a GeoJSON FeatureCollection by scanning raw bytes and decoding each feature
    /// individually, avoiding full-document memory overhead.
    ///
    /// - Parameter filter: Optional spatial predicate evaluated on each feature's geometry.
    ///   If provided, geometry is decoded first; features that don't pass are skipped entirely
    ///   without retaining their properties — keeping peak memory low for large datasets.
    ///   Pass `nil` to decode all features.
    static func parseFeatures(from data: Data, filter: ((GeometryFeature) -> Bool)? = nil) -> [GeoAPIFeature] {
        guard !data.isEmpty else { return [] }
        guard let arrayStart = findFeaturesArrayStart(data: data) else {
            POIKitLogger.e("[GeoJSONStreamParser] Could not find 'features' array in GeoJSON data")
            return []
        }
        return decodeFeatures(from: data, startingAt: arrayStart, filter: filter)
    }

    // MARK: - Private helpers

    /// Advances `pos` past a JSON string. On entry `pos` must point to the opening `"`.
    private static func skipString(data: Data, pos: inout Int) {
        pos += 1
        while pos < data.count {
            let c = data[pos]
            if c == 0x5C { pos += 2 }          // backslash — skip escaped char
            else if c == 0x22 { pos += 1; return } // closing quote
            else { pos += 1 }
        }
    }

    /// Scans `data` to find the index just after the opening `[` of the `"features"` array.
    private static func findFeaturesArrayStart(data: Data) -> Int? {
        let count = data.count
        let keyLen = featuresKey.count
        var i = 0
        var depth = 0

        while i < count {
            switch data[i] {
            case 0x22: // quote — check for "features" key at root-object depth
                if depth == 1, i + keyLen <= count,
                   data[i..<(i + keyLen)].elementsEqual(featuresKey) {
                    i += keyLen
                    if let arrayStart = scanForArrayOpen(data: data, from: i) {
                        return arrayStart
                    }
                } else {
                    skipString(data: data, pos: &i)
                }

            case 0x7B, 0x5B:
                depth += 1; i += 1

            case 0x7D, 0x5D:
                depth -= 1; i += 1
                if depth < 0 { return nil }

            default:
                i += 1
            }
        }
        return nil
    }

    /// Scans forward from `start` to find the opening `[` of an array value, returning the
    /// index immediately after it. Returns `nil` if something else (e.g. a string) comes first.
    private static func scanForArrayOpen(data: Data, from start: Int) -> Int? {
        var i = start
        while i < data.count {
            if data[i] == 0x5B { return i + 1 }   // `[` found
            if data[i] == 0x22 { return nil }      // unexpected string value
            i += 1
        }
        return nil
    }

    /// Iterates through the features array, decoding each `{…}` object with JSONSerialization.
    /// Geometry is decoded first; if `filter` rejects it, properties are not retained.
    /// Uses autoreleasepool per feature to release Foundation temporaries promptly.
    private static func decodeFeatures(from data: Data,
                                       startingAt start: Int,
                                       filter: ((GeometryFeature) -> Bool)?) -> [GeoAPIFeature] {
        var features: [GeoAPIFeature] = []
        let decoder = JSONDecoder()
        var i = start

        while i < data.count {
            switch data[i] {
            case 0x20, 0x09, 0x0A, 0x0D, 0x2C:
                i += 1

            case 0x5D:
                return features

            case 0x7B:                                    // `{` start of feature
                guard let end = findFeatureEnd(data: data, startingAt: i) else {
                    POIKitLogger.e("[GeoJSONStreamParser] Unterminated feature object in GeoJSON data")
                    return features
                }
                autoreleasepool {
                    do {
                        guard let obj = try JSONSerialization.jsonObject(with: data[i...end]) as? [String: Any] else { return }
                        var geometry: GeometryFeature?
                        if let geometryDict = obj["geometry"] {
                            let geometryData = try JSONSerialization.data(withJSONObject: geometryDict)
                            geometry = try decoder.decode(GeometryFeature.self, from: geometryData)
                        }
                        if let filter = filter, let geometry = geometry, !filter(geometry) {
                            return
                        }
                        let id = obj["id"] as? String
                        let type = obj["type"] as? String
                        let properties = obj["properties"] as? [String: Any]
                        let feature = GeoAPIFeature(id: id, type: type, geometry: geometry, properties: properties)
                        features.append(feature)
                    } catch {
                        POIKitLogger.e("[GeoJSONStreamParser] Failed to decode feature: \(error)")
                    }
                }
                i = end + 1

            default:
                i += 1
            }
        }
        return features
    }

    /// Returns the index of the closing `}` that matches the opening `{` at `start`,
    /// tracking nesting depth and skipping string contents.
    private static func findFeatureEnd(data: Data, startingAt start: Int) -> Int? {
        let count = data.count
        var depth = 0
        var j = start

        while j < count {
            switch data[j] {
            case 0x22:
                skipString(data: data, pos: &j)

            case 0x7B, 0x5B:
                depth += 1; j += 1

            case 0x7D, 0x5D:
                depth -= 1
                if depth == 0 { return j }
                j += 1

            default:
                j += 1
            }
        }
        return nil
    }
}
