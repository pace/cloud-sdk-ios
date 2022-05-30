//
// Generated by SwagGen
// https://github.com/pace/SwagGen
//

import Foundation

public class PCPOILocationBasedAppWithRefs: APIModel {

    /** Type */
    public enum PCPOIType: String, Codable, Equatable, CaseIterable {
        case locationBasedAppWithRefs = "locationBasedAppWithRefs"
    }

    public enum PCPOIAppType: String, Codable, Equatable, CaseIterable {
        case fueling = "fueling"
    }

    /** A location-based app is by default loaded on `approaching`. Some apps should be loaded in advance. They have the cache set to `preload`.
     */
    public enum PCPOICache: String, Codable, Equatable, CaseIterable {
        case approaching = "approaching"
        case preload = "preload"
    }

    /** Location-based app ID */
    public var id: ID?

    /** Type */
    public var type: PCPOIType?

    /** Android instant app URL */
    public var androidInstantAppUrl: String?

    public var appType: PCPOIAppType?

    /** A location-based app is by default loaded on `approaching`. Some apps should be loaded in advance. They have the cache set to `preload`.
 */
    public var cache: PCPOICache?

    /** Time of LocationBasedApp creation (iso8601 without time zone) */
    public var createdAt: DateTime?

    /** Time of LocationBasedApp deletion (iso8601 without time zone) */
    public var deletedAt: DateTime?

    /** Logo URL */
    public var logoUrl: String?

    /** Progressive web application URL. The URL satisfies the following criteria: <li>The URL responds with `text/html` on a GET request</li> <li>The response contains HTTP caching headers e.g. `Cache-Control` and `ETag`</li> <li>HTTP GET request on the URL with an `ETag` will return `304` (`Not Modified`), if the content didn't change</li> <li>If `503` (`Service Unavailable`) is returned the request should be retried later</li> <li>If `404` (`Not Found`) is returned the URL is invalidated and a new app should be requested</li>
 */
    public var pwaUrl: String?

    /** References are PRNs to external and internal resources that are related to the query */
    public var references: [String]?

    public var subtitle: String?

    public var title: String?

    /** Time of LocationBasedApp last update (iso8601 without time zone) */
    public var updatedAt: DateTime?

    public init(id: ID? = nil, type: PCPOIType? = nil, androidInstantAppUrl: String? = nil, appType: PCPOIAppType? = nil, cache: PCPOICache? = nil, createdAt: DateTime? = nil, deletedAt: DateTime? = nil, logoUrl: String? = nil, pwaUrl: String? = nil, references: [String]? = nil, subtitle: String? = nil, title: String? = nil, updatedAt: DateTime? = nil) {
        self.id = id
        self.type = type
        self.androidInstantAppUrl = androidInstantAppUrl
        self.appType = appType
        self.cache = cache
        self.createdAt = createdAt
        self.deletedAt = deletedAt
        self.logoUrl = logoUrl
        self.pwaUrl = pwaUrl
        self.references = references
        self.subtitle = subtitle
        self.title = title
        self.updatedAt = updatedAt
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StringCodingKey.self)

        id = try container.decodeIfPresent("id")
        type = try container.decodeIfPresent("type")
        androidInstantAppUrl = try container.decodeIfPresent("androidInstantAppUrl")
        appType = try container.decodeIfPresent("appType")
        cache = try container.decodeIfPresent("cache")
        createdAt = try container.decodeIfPresent("createdAt")
        deletedAt = try container.decodeIfPresent("deletedAt")
        logoUrl = try container.decodeIfPresent("logoUrl")
        pwaUrl = try container.decodeIfPresent("pwaUrl")
        references = try container.decodeArrayIfPresent("references")
        subtitle = try container.decodeIfPresent("subtitle")
        title = try container.decodeIfPresent("title")
        updatedAt = try container.decodeIfPresent("updatedAt")
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StringCodingKey.self)

        try container.encodeIfPresent(id, forKey: "id")
        try container.encodeIfPresent(type, forKey: "type")
        try container.encodeIfPresent(androidInstantAppUrl, forKey: "androidInstantAppUrl")
        try container.encodeIfPresent(appType, forKey: "appType")
        try container.encodeIfPresent(cache, forKey: "cache")
        try container.encodeIfPresent(createdAt, forKey: "createdAt")
        try container.encodeIfPresent(deletedAt, forKey: "deletedAt")
        try container.encodeIfPresent(logoUrl, forKey: "logoUrl")
        try container.encodeIfPresent(pwaUrl, forKey: "pwaUrl")
        try container.encodeIfPresent(references, forKey: "references")
        try container.encodeIfPresent(subtitle, forKey: "subtitle")
        try container.encodeIfPresent(title, forKey: "title")
        try container.encodeIfPresent(updatedAt, forKey: "updatedAt")
    }

    public func isEqual(to object: Any?) -> Bool {
      guard let object = object as? PCPOILocationBasedAppWithRefs else { return false }
      guard self.id == object.id else { return false }
      guard self.type == object.type else { return false }
      guard self.androidInstantAppUrl == object.androidInstantAppUrl else { return false }
      guard self.appType == object.appType else { return false }
      guard self.cache == object.cache else { return false }
      guard self.createdAt == object.createdAt else { return false }
      guard self.deletedAt == object.deletedAt else { return false }
      guard self.logoUrl == object.logoUrl else { return false }
      guard self.pwaUrl == object.pwaUrl else { return false }
      guard self.references == object.references else { return false }
      guard self.subtitle == object.subtitle else { return false }
      guard self.title == object.title else { return false }
      guard self.updatedAt == object.updatedAt else { return false }
      return true
    }

    public static func == (lhs: PCPOILocationBasedAppWithRefs, rhs: PCPOILocationBasedAppWithRefs) -> Bool {
        return lhs.isEqual(to: rhs)
    }
}
