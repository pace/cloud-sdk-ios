//
// Generated by SwagGen
// https://github.com/pace/SwagGen
//

import Foundation

/** https://tools.ietf.org/html/rfc7946#section-3.1.2 */
public class PCPOICommonGeoJSONPoint: APIModel {

    /** https://tools.ietf.org/html/rfc7946#section-3.1.2 */
    public enum PCPOIType: String, Codable, Equatable, CaseIterable {
        case point = "Point"
    }

    /** https://tools.ietf.org/html/rfc7946 */
    public var coordinates: [Float]?

    public var type: PCPOIType?

    public init(coordinates: [Float]? = nil, type: PCPOIType? = nil) {
        self.coordinates = coordinates
        self.type = type
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StringCodingKey.self)

        coordinates = try container.decodeArrayIfPresent("coordinates")
        type = try container.decodeIfPresent("type")
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StringCodingKey.self)

        try container.encodeIfPresent(coordinates, forKey: "coordinates")
        try container.encodeIfPresent(type, forKey: "type")
    }

    public func isEqual(to object: Any?) -> Bool {
      guard let object = object as? PCPOICommonGeoJSONPoint else { return false }
      guard self.coordinates == object.coordinates else { return false }
      guard self.type == object.type else { return false }
      return true
    }

    public static func == (lhs: PCPOICommonGeoJSONPoint, rhs: PCPOICommonGeoJSONPoint) -> Bool {
        return lhs.isEqual(to: rhs)
    }
}
