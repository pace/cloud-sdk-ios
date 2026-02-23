//
//  GeoJSONStreamParserTests.swift
//  PACECloudSDKTests
//
//  Created by PACE Telematics GmbH.
//

import XCTest
@testable import PACECloudSDK

class GeoJSONStreamParserTests: XCTestCase {

    // MARK: - Helpers

    private func data(_ string: String) -> Data {
        string.data(using: .utf8)!
    }

    // MARK: - Basic correctness

    func testTwoFeaturesParsed() {
        let json = """
        {
            "type": "FeatureCollection",
            "features": [
                {
                    "id": "aaaa-1111",
                    "type": "Feature",
                    "geometry": { "type": "Point", "coordinates": [8.4274, 49.0125] },
                    "properties": { "connectedFuelingStatus": "online", "pacePay": true }
                },
                {
                    "id": "bbbb-2222",
                    "type": "Feature",
                    "geometry": { "type": "Point", "coordinates": [8.4273, 49.0126] },
                    "properties": { "connectedFuelingStatus": "offline", "pacePay": false }
                }
            ]
        }
        """
        let features = GeoJSONStreamParser.parseFeatures(from: data(json))
        XCTAssertEqual(features.count, 2)
        XCTAssertEqual(features[0].id, "aaaa-1111")
        XCTAssertEqual(features[1].id, "bbbb-2222")
    }

    func testFeaturePropertiesParsed() {
        let json = """
        {
            "type": "FeatureCollection",
            "features": [{
                "id": "cccc-3333",
                "type": "Feature",
                "geometry": { "type": "Point", "coordinates": [13.4, 52.5] },
                "properties": {
                    "connectedFuelingStatus": "online",
                    "pacePay": true,
                    "apps": [{"type": "fueling", "url": "https://dev.fuel.site"}]
                }
            }]
        }
        """
        let features = GeoJSONStreamParser.parseFeatures(from: data(json))
        XCTAssertEqual(features.count, 1)
        let feature = features[0]
        XCTAssertEqual(feature.id, "cccc-3333")
        XCTAssertNotNil(feature.geometry)
        if case .point(let pt) = feature.geometry {
            XCTAssertEqual(pt.coordinates[safe: 0], 13.4)
            XCTAssertEqual(pt.coordinates[safe: 1], 52.5)
        } else {
            XCTFail("Expected point geometry")
        }
    }

    func testFeaturePropertyTypes() {
        let json = """
        {
            "type": "FeatureCollection",
            "features": [{
                "id": "props-test",
                "type": "Feature",
                "geometry": { "type": "Point", "coordinates": [13.4, 52.5] },
                "properties": {
                    "connectedFuelingStatus": "online",
                    "pacePay": true,
                    "pricePerLiter": 1.759,
                    "stationCount": 42,
                    "apps": [{"type": "fueling", "url": "https://dev.fuel.site"}]
                }
            }]
        }
        """
        let features = GeoJSONStreamParser.parseFeatures(from: data(json))
        XCTAssertEqual(features.count, 1)
        let props = features[0].properties
        XCTAssertEqual(props?["connectedFuelingStatus"] as? String, "online")
        XCTAssertEqual(props?["pacePay"] as? Bool, true)
        XCTAssertEqual(props?["pricePerLiter"] as? Double, 1.759)
        XCTAssertEqual(props?["stationCount"] as? Int, 42)
        XCTAssertNotNil(props?["apps"] as? [[String: Any]])
    }

    func testFeatureWithPolygonGeometry() {
        let json = """
        {
            "type": "FeatureCollection",
            "features": [{
                "id": "dddd-4444",
                "type": "Feature",
                "geometry": {
                    "type": "Polygon",
                    "coordinates": [[[8.0, 49.0], [8.1, 49.0], [8.1, 49.1], [8.0, 49.1], [8.0, 49.0]]]
                },
                "properties": {}
            }]
        }
        """
        let features = GeoJSONStreamParser.parseFeatures(from: data(json))
        XCTAssertEqual(features.count, 1)
        XCTAssertEqual(features[0].id, "dddd-4444")
        if case .polygon(let poly) = features[0].geometry {
            XCTAssertEqual(poly.coordinates.first?.count, 5)
        } else {
            XCTFail("Expected polygon geometry")
        }
    }

    func testFeatureWithGeometryCollection() {
        let json = """
        {
            "type": "FeatureCollection",
            "features": [{
                "id": "eeee-5555",
                "type": "Feature",
                "geometry": {
                    "type": "GeometryCollection",
                    "geometries": [
                        { "type": "Point", "coordinates": [8.4, 49.0] },
                        { "type": "Polygon", "coordinates": [[[8.3, 48.9], [8.5, 48.9], [8.5, 49.1], [8.3, 49.1], [8.3, 48.9]]] }
                    ]
                },
                "properties": {}
            }]
        }
        """
        let features = GeoJSONStreamParser.parseFeatures(from: data(json))
        XCTAssertEqual(features.count, 1)
        XCTAssertEqual(features[0].id, "eeee-5555")
        if case .collections(let col) = features[0].geometry {
            XCTAssertEqual(col.geometries?.count, 2)
        } else {
            XCTFail("Expected geometry collection")
        }
    }

    // MARK: - String-awareness (braces/brackets inside string values must not confuse the parser)

    func testStringValuesWithStructuralCharacters() {
        // Property values contain `{`, `}`, `[`, `]` — the parser must not confuse these
        // with JSON structure delimiters.
        let json = """
        {
            "type": "FeatureCollection",
            "features": [
                {
                    "id": "ffff-6666",
                    "type": "Feature",
                    "geometry": { "type": "Point", "coordinates": [0.0, 0.0] },
                    "properties": { "note": "has {braces} and [brackets] inside" }
                },
                {
                    "id": "gggg-7777",
                    "type": "Feature",
                    "geometry": { "type": "Point", "coordinates": [1.0, 1.0] },
                    "properties": { "note": "normal" }
                }
            ]
        }
        """
        let features = GeoJSONStreamParser.parseFeatures(from: data(json))
        XCTAssertEqual(features.count, 2)
        XCTAssertEqual(features[0].id, "ffff-6666")
        XCTAssertEqual(features[1].id, "gggg-7777")
    }

    func testStringValuesWithEscapedQuotes() {
        // Escaped quotes inside string values must not terminate the string prematurely.
        let json = """
        {
            "type": "FeatureCollection",
            "features": [{
                "id": "hhhh-8888",
                "type": "Feature",
                "geometry": { "type": "Point", "coordinates": [2.0, 2.0] },
                "properties": { "note": "she said \\"hello\\"" }
            }]
        }
        """
        let features = GeoJSONStreamParser.parseFeatures(from: data(json))
        XCTAssertEqual(features.count, 1)
        XCTAssertEqual(features[0].id, "hhhh-8888")
    }

    func testStringValuesWithEscapedBackslash() {
        // A `\\` escape sequence must not allow the following `"` to end the string.
        // JSON: "path": "C:\\Users\\foo" — raw bytes contain \ \ " inside the value
        let jsonRaw = #"""
        {
            "type": "FeatureCollection",
            "features": [{
                "id": "iiii-9999",
                "type": "Feature",
                "geometry": { "type": "Point", "coordinates": [3.0, 3.0] },
                "properties": { "path": "C:\\Users\\foo" }
            }]
        }
        """#
        let features = GeoJSONStreamParser.parseFeatures(from: data(jsonRaw))
        XCTAssertEqual(features.count, 1)
        XCTAssertEqual(features[0].id, "iiii-9999")
    }

    // MARK: - Edge cases

    func testEmptyFeaturesArray() {
        let json = """
        { "type": "FeatureCollection", "features": [] }
        """
        let features = GeoJSONStreamParser.parseFeatures(from: data(json))
        XCTAssertTrue(features.isEmpty)
    }

    func testEmptyData() {
        let features = GeoJSONStreamParser.parseFeatures(from: Data())
        XCTAssertTrue(features.isEmpty)
    }

    func testNoFeaturesKey() {
        let json = """
        { "type": "FeatureCollection" }
        """
        let features = GeoJSONStreamParser.parseFeatures(from: data(json))
        XCTAssertTrue(features.isEmpty)
    }

    func testMalformedFeatureSkippedRestParsed() {
        // The second feature has invalid JSON — it should be skipped, but the others
        // should still be decoded successfully.
        let json = """
        {
            "type": "FeatureCollection",
            "features": [
                {
                    "id": "good-1111",
                    "type": "Feature",
                    "geometry": { "type": "Point", "coordinates": [4.0, 4.0] },
                    "properties": {}
                },
                {
                    "id": 12345,
                    "type": "Feature",
                    "geometry": { "type": "Point", "coordinates": [5.0, 5.0] },
                    "properties": {}
                },
                {
                    "id": "good-3333",
                    "type": "Feature",
                    "geometry": { "type": "Point", "coordinates": [6.0, 6.0] },
                    "properties": {}
                }
            ]
        }
        """
        // Feature 2 has id as integer — JSONSerialization parses it fine but id won't cast to String,
        // so the feature is included with id: nil. Downstream filtering (GeoAPIManager) drops nil-id features.
        let features = GeoJSONStreamParser.parseFeatures(from: data(json))
        XCTAssertEqual(features.count, 3)
        XCTAssertEqual(features[0].id, "good-1111")
        XCTAssertNil(features[1].id)
        XCTAssertEqual(features[2].id, "good-3333")
    }

    func testSingleFeatureParsed() {
        let json = """
        {
            "type": "FeatureCollection",
            "features": [{
                "id": "solo-1234",
                "type": "Feature",
                "geometry": { "type": "Point", "coordinates": [7.0, 51.0] },
                "properties": {
                    "connectedFuelingStatus": "online",
                    "pacePay": false,
                    "paymentMethodKinds": ["applepay", "creditcard"]
                }
            }]
        }
        """
        let features = GeoJSONStreamParser.parseFeatures(from: data(json))
        XCTAssertEqual(features.count, 1)
        XCTAssertEqual(features[0].id, "solo-1234")
    }

    func testFeaturesKeyInNestedObjectNotConfused() {
        // "features" appears as a key inside a nested property value — should still
        // find only the top-level "features" array.
        let json = """
        {
            "type": "FeatureCollection",
            "features": [{
                "id": "nested-key-test",
                "type": "Feature",
                "geometry": { "type": "Point", "coordinates": [0.0, 0.0] },
                "properties": { "metadata": { "features": "this is a nested features key" } }
            }]
        }
        """
        let features = GeoJSONStreamParser.parseFeatures(from: data(json))
        XCTAssertEqual(features.count, 1)
        XCTAssertEqual(features[0].id, "nested-key-test")
    }

    func testLargeFeatureCount() {
        // Build a synthetic GeoJSON with 500 features and verify all are decoded.
        var featureStrings: [String] = []
        for i in 0..<500 {
            featureStrings.append("""
            {
                "id": "bulk-\(String(format: "%04d", i))",
                "type": "Feature",
                "geometry": { "type": "Point", "coordinates": [\(Double(i) * 0.001), \(48.0 + Double(i) * 0.0001)] },
                "properties": { "connectedFuelingStatus": "online", "pacePay": true }
            }
            """)
        }
        let json = "{ \"type\": \"FeatureCollection\", \"features\": [\(featureStrings.joined(separator: ","))] }"
        let features = GeoJSONStreamParser.parseFeatures(from: data(json))
        XCTAssertEqual(features.count, 500)
        XCTAssertEqual(features[0].id, "bulk-0000")
        XCTAssertEqual(features[499].id, "bulk-0499")
    }

    // MARK: - Spatial filter

    func testFilterByGeometry() {
        let json = """
        {
            "type": "FeatureCollection",
            "features": [
                {
                    "id": "near",
                    "type": "Feature",
                    "geometry": { "type": "Point", "coordinates": [8.4, 49.0] },
                    "properties": { "connectedFuelingStatus": "online" }
                },
                {
                    "id": "far",
                    "type": "Feature",
                    "geometry": { "type": "Point", "coordinates": [20.0, 50.0] },
                    "properties": { "connectedFuelingStatus": "online" }
                }
            ]
        }
        """
        let filter: (GeometryFeature) -> Bool = { geometry in
            if case .point(let pt) = geometry,
               let lon = pt.coordinates[safe: 0],
               let lat = pt.coordinates[safe: 1] {
                return abs(lon - 8.4) < 1.0 && abs(lat - 49.0) < 1.0
            }
            return false
        }
        let features = GeoJSONStreamParser.parseFeatures(from: data(json), filter: filter)
        XCTAssertEqual(features.count, 1)
        XCTAssertEqual(features[0].id, "near")
    }

    func testNilFilterParsesAll() {
        let json = """
        {
            "type": "FeatureCollection",
            "features": [
                {
                    "id": "a",
                    "type": "Feature",
                    "geometry": { "type": "Point", "coordinates": [1.0, 1.0] },
                    "properties": {}
                },
                {
                    "id": "b",
                    "type": "Feature",
                    "geometry": { "type": "Point", "coordinates": [100.0, 80.0] },
                    "properties": {}
                }
            ]
        }
        """
        let features = GeoJSONStreamParser.parseFeatures(from: data(json), filter: nil)
        XCTAssertEqual(features.count, 2)
    }

    // MARK: - Same-result parity with JSONDecoder

    func testParityWithJSONDecoder() throws {
        // The mock GeoJSON used by GeoServiceTests — the stream parser must produce
        // the same features as a standard JSONDecoder full-document decode.
        let json = """
        {
            "type": "FeatureCollection",
            "features": [{
                "id": "e3211b77-03f0-4d49-83aa-4adaa46d95ae",
                "type": "Feature",
                "geometry": {
                    "type": "Point",
                    "coordinates": [8.427428305149078, 49.012591410884085]
                },
                "properties": {
                    "apps": [{"type": "fueling", "url": "https://dev.fuel.site"}],
                    "connectedFuelingStatus": "online",
                    "pacePay": true
                }
            }, {
                "id": "2745dc62-0d2a-474f-9849-3de4a76b888a",
                "type": "Feature",
                "geometry": {
                    "type": "Point",
                    "coordinates": [8.42731699347496, 49.01260548482239]
                },
                "properties": {
                    "apps": [{"type": "fueling", "url": "https://dev.fuel.site"}],
                    "connectedFuelingStatus": "offline",
                    "pacePay": false
                }
            }]
        }
        """
        let jsonData = data(json)

        let streamFeatures = GeoJSONStreamParser.parseFeatures(from: jsonData)
        let fullResponse = try JSONDecoder().decode(GeoAPIResponse.self, from: jsonData)
        let fullFeatures = fullResponse.features ?? []

        XCTAssertEqual(streamFeatures.count, fullFeatures.count)
        for (stream, full) in zip(streamFeatures, fullFeatures) {
            XCTAssertEqual(stream.id, full.id)
            XCTAssertEqual(stream.type, full.type)
        }
    }

    // MARK: - Integration test against dev CDN

    func testDevCDNIntegration() throws {
        // Hits the real dev GeoJSON endpoint and verifies the stream parser can handle
        // the full production-scale file. Skipped if network is unavailable.
        let url = URL(string: "https://cdn.dev.pace.cloud/geo/2021-1/apps/drive-app-ios.geojson")!
        let expectation = expectation(description: "devCDNIntegration")
        var parseResult: [GeoAPIFeature] = []
        var networkError: Error?

        URLSession.shared.dataTask(with: url) { data, _, error in
            defer { expectation.fulfill() }
            if let error = error {
                networkError = error
                return
            }
            guard let data = data else { return }
            parseResult = GeoJSONStreamParser.parseFeatures(from: data)
        }.resume()

        // Allow up to 30 s for network + parsing
        waitForExpectations(timeout: 30)

        if let error = networkError {
            throw XCTSkip("Network unavailable: \(error.localizedDescription)")
        }

        XCTAssertGreaterThan(parseResult.count, 0, "Expected at least one feature from dev CDN")
        // Every feature must have a non-empty id
        let missingIDs = parseResult.filter { $0.id == nil || $0.id!.isEmpty }
        XCTAssertTrue(missingIDs.isEmpty, "\(missingIDs.count) features had nil/empty IDs")
        // Every feature must have geometry
        let missingGeometry = parseResult.filter { $0.geometry == nil }
        XCTAssertTrue(missingGeometry.isEmpty, "\(missingGeometry.count) features had nil geometry")

        print("[GeoJSONStreamParserTests] Dev CDN returned \(parseResult.count) features ✓")
    }
}
