//
//  GeoAPIResponse.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation
internal import IkigaJSON

struct GeoAPIResponse: Decodable {
    let type: String?
    let features: [GeoAPIFeature]?
}

struct GeoAPIFeature: Decodable {
    let id, type: String?
    let geometry: GeometryFeature?
    let properties: [String: AnyCodable]?

    enum CodingKeys: String, CodingKey {
        case id
        case type
        case geometry
        case properties
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        type = try values.decode(String.self, forKey: .type)
        geometry = try values.decode(GeometryFeature.self, forKey: .geometry)
        properties = try values.decode([String: AnyCodable].self, forKey: .properties)
    }
}

enum GeometryFeature: Codable {
    case point(GeometryPointFeature)
    case polygon(GeometryPolygonFeature)
    case collections(GeometryCollectionsFeature)

    init?(from jsonObject: JSONObject) {
        guard let type = jsonObject["type"] as? String else { return nil }

        switch type.lowercased() {
        case "point":
            guard let jsonArray = jsonObject["coordinates"] as? JSONArray,
                  let pointFeature = GeometryPointFeature(jsonArray: jsonArray) else { return nil }
            self = .point(pointFeature)

        case "polygon":
            guard let coordinatesArray = jsonObject["coordinates"] as? [[[Double]]] else { return nil }
            let coordinates = coordinatesArray.map { $0.map { $0 } }
            let polygonFeature = GeometryPolygonFeature(type: type, coordinates: coordinates)
            self = .polygon(polygonFeature)

        case "geometrycollection":
            let geometriesArray = jsonObject["geometries"] as? [JSONObject]
            var geometries: [GeometryFeature]? = nil
            
            if let geometriesArray = geometriesArray {
                geometries = geometriesArray.compactMap { GeometryFeature(from: $0) }
            }
            
            let collectionsFeature = GeometryCollectionsFeature(type: type, geometries: geometries)
            self = .collections(collectionsFeature)
            
        default:
            return nil
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(GeometryPolygonFeature.self) {
            self = .polygon(x)
            return
        }

        if let x = try? container.decode(GeometryPointFeature.self) {
            self = .point(x)
            return
        }

        if let x = try? container.decode(GeometryCollectionsFeature.self) {
            self = .collections(x)
            return
        }

        throw DecodingError.typeMismatch(GeometryFeature.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for GeometryFeature"))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .point(let x):
            try container.encode(x)

        case .polygon(let x):
            try container.encode(x)

        case .collections(let x):
            try container.encode(x)
        }
    }
}

struct GeometryPointFeature: Codable {
    let coordinates: GeoAPICoordinate

    init?(jsonArray: JSONArray) {
        var coordinates: [Double] = []
        for coordinate in jsonArray {
            if let doubleCoordinate = coordinate.double {
                coordinates.append(doubleCoordinate)
            }
        }

        guard coordinates.count == 2 else { return nil }
        self.coordinates = coordinates
    }
}

struct GeometryPolygonFeature: Codable {
    let type: String?
    let coordinates: [GeoAPICoordinates]
}

struct GeometryCollectionsFeature: Codable {
    let type: String?
    let geometries: [GeometryFeature]?
}

public typealias GeoAPICoordinates = [GeoAPICoordinate]
public typealias GeoAPICoordinate = [Double]
