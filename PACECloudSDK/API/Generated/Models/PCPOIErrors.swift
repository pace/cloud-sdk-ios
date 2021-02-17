//
// Generated by SwagGen
// https://github.com/pace/SwagGen
//

import Foundation

/** Error objects provide additional information about problems encountered while performing an operation.
Errors also contain codes besides title and message which can be used for checks even if the detailed messages might change.
    * code `1000`:  generic error
    * code `1001`:  payment processing temporarily unavailable
    * code `1002`:  requested amount exceeds the authorized amount of the provided token
    * code `1003`:  implicit payment methods cannot be modified
    * code `1004`:  payment method rejected by provider
 */
public class PCPOIErrors: APIModel {

    public var errors: [Errors]?

    /** Error objects provide additional information about problems encountered while performing an operation.
    Errors also contain codes besides title and message which can be used for checks even if the detailed messages might change.
        * code `1000`:  generic error
        * code `1001`:  payment processing temporarily unavailable
        * code `1002`:  requested amount exceeds the authorized amount of the provided token
        * code `1003`:  implicit payment methods cannot be modified
        * code `1004`:  payment method rejected by provider
     */
    public class Errors: APIModel {

        /** an application-specific error code, expressed as a string value.
     */
        public var code: String?

        /** a human-readable explanation specific to this occurrence of the problem. Like title, this field’s value can be localized.
     */
        public var detail: String?

        /** A unique identifier for this particular occurrence of the problem. */
        public var id: String?

        public var links: Links?

        /** a meta object containing non-standard meta-information about the error.
     */
        public var meta: [String: Any]?

        /** An object containing references to the source of the error.
     */
        public var source: Source?

        /** the HTTP status code applicable to this problem, expressed as a string value.
     */
        public var status: String?

        /** A short, human-readable summary of the problem that SHOULD NOT change from occurrence to occurrence of the problem, except for purposes of localization.
     */
        public var title: String?

        /** Error objects provide additional information about problems encountered while performing an operation.
        Errors also contain codes besides title and message which can be used for checks even if the detailed messages might change.
            * code `1000`:  generic error
            * code `1001`:  payment processing temporarily unavailable
            * code `1002`:  requested amount exceeds the authorized amount of the provided token
            * code `1003`:  implicit payment methods cannot be modified
            * code `1004`:  payment method rejected by provider
         */
        public class Links: APIModel {

            /** A link that leads to further details about this particular occurrence of the problem.
         */
            public var about: String?

            public init(about: String? = nil) {
                self.about = about
            }

            public required init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: StringCodingKey.self)

                about = try container.decodeIfPresent("about")
            }

            public func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: StringCodingKey.self)

                try container.encodeIfPresent(about, forKey: "about")
            }

            public func isEqual(to object: Any?) -> Bool {
              guard let object = object as? Links else { return false }
              guard self.about == object.about else { return false }
              return true
            }

            public static func == (lhs: Links, rhs: Links) -> Bool {
                return lhs.isEqual(to: rhs)
            }
        }

        /** An object containing references to the source of the error.
         */
        public class Source: APIModel {

            /** A string indicating which URI query parameter caused the error.
         */
            public var parameter: String?

            /** A JSON Pointer [RFC6901] to the associated entity in the request document [e.g. "/data" for a primary data object, or "/data/attributes/title" for a specific attribute].
         */
            public var pointer: String?

            public init(parameter: String? = nil, pointer: String? = nil) {
                self.parameter = parameter
                self.pointer = pointer
            }

            public required init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: StringCodingKey.self)

                parameter = try container.decodeIfPresent("parameter")
                pointer = try container.decodeIfPresent("pointer")
            }

            public func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: StringCodingKey.self)

                try container.encodeIfPresent(parameter, forKey: "parameter")
                try container.encodeIfPresent(pointer, forKey: "pointer")
            }

            public func isEqual(to object: Any?) -> Bool {
              guard let object = object as? Source else { return false }
              guard self.parameter == object.parameter else { return false }
              guard self.pointer == object.pointer else { return false }
              return true
            }

            public static func == (lhs: Source, rhs: Source) -> Bool {
                return lhs.isEqual(to: rhs)
            }
        }

        public init(code: String? = nil, detail: String? = nil, id: String? = nil, links: Links? = nil, meta: [String: Any]? = nil, source: Source? = nil, status: String? = nil, title: String? = nil) {
            self.code = code
            self.detail = detail
            self.id = id
            self.links = links
            self.meta = meta
            self.source = source
            self.status = status
            self.title = title
        }

        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: StringCodingKey.self)

            code = try container.decodeIfPresent("code")
            detail = try container.decodeIfPresent("detail")
            id = try container.decodeIfPresent("id")
            links = try container.decodeIfPresent("links")
            meta = try container.decodeAnyIfPresent("meta")
            source = try container.decodeIfPresent("source")
            status = try container.decodeIfPresent("status")
            title = try container.decodeIfPresent("title")
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: StringCodingKey.self)

            try container.encodeIfPresent(code, forKey: "code")
            try container.encodeIfPresent(detail, forKey: "detail")
            try container.encodeIfPresent(id, forKey: "id")
            try container.encodeIfPresent(links, forKey: "links")
            try container.encodeAnyIfPresent(meta, forKey: "meta")
            try container.encodeIfPresent(source, forKey: "source")
            try container.encodeIfPresent(status, forKey: "status")
            try container.encodeIfPresent(title, forKey: "title")
        }

        public func isEqual(to object: Any?) -> Bool {
          guard let object = object as? Errors else { return false }
          guard self.code == object.code else { return false }
          guard self.detail == object.detail else { return false }
          guard self.id == object.id else { return false }
          guard self.links == object.links else { return false }
          guard NSDictionary(dictionary: self.meta ?? [:]).isEqual(to: object.meta ?? [:]) else { return false }
          guard self.source == object.source else { return false }
          guard self.status == object.status else { return false }
          guard self.title == object.title else { return false }
          return true
        }

        public static func == (lhs: Errors, rhs: Errors) -> Bool {
            return lhs.isEqual(to: rhs)
        }
    }

    public init(errors: [Errors]? = nil) {
        self.errors = errors
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StringCodingKey.self)

        errors = try container.decodeArrayIfPresent("errors")
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StringCodingKey.self)

        try container.encodeIfPresent(errors, forKey: "errors")
    }

    public func isEqual(to object: Any?) -> Bool {
      guard let object = object as? PCPOIErrors else { return false }
      guard self.errors == object.errors else { return false }
      return true
    }

    public static func == (lhs: PCPOIErrors, rhs: PCPOIErrors) -> Bool {
        return lhs.isEqual(to: rhs)
    }
}