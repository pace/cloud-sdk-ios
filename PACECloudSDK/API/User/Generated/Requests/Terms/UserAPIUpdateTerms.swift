//
// Generated by SwagGen
// https://github.com/pace/SwagGen
//

import Foundation

extension UserAPI.Terms {

    /**
    Update the terms cache

    Triggers an update to the terms cache.
    */
    public enum UpdateTerms {

        public static var service = UserAPIService<Response>(id: "UpdateTerms", tag: "Terms", method: "PUT", path: "/terms/update", hasBody: false, securityRequirements: [SecurityRequirement(type: "OAuth2", scopes: ["user:terms:update"]), SecurityRequirement(type: "OIDC", scopes: ["user:terms:update"])])

        public final class Request: UserAPIRequest<Response> {

            public init() {
                super.init(service: UpdateTerms.service)
            }

            public override var isAuthorizationRequired: Bool {
                true
            }
        }

        public enum Response: APIResponseValue, CustomStringConvertible, CustomDebugStringConvertible {

            /** Error objects provide additional information about problems encountered while performing an operation.
            Errors also contain codes besides title and message which can be used for checks even if the detailed messages might change.
                * `1000`:  generic error
                * `1001`:  payment processing temporarily unavailable
                * `1002`:  requested amount exceeds the authorized amount of the provided token
                * `1003`:  implicit payment methods cannot be modified
                * `1004`:  payment method rejected by provider
                * `provider:payment-method-rejected`:  payment method rejected by provider (identical to `1004`)
                * `rule:product-denied`: Product restrictions forbid transaction, e.g., forbidden fuel type - token authorized only for Diesel but attempted to fuel Super.
             */
            public class Status401: APIModel {

                public var errors: [Errors]?

                /** Error objects provide additional information about problems encountered while performing an operation.
                Errors also contain codes besides title and message which can be used for checks even if the detailed messages might change.
                    * `1000`:  generic error
                    * `1001`:  payment processing temporarily unavailable
                    * `1002`:  requested amount exceeds the authorized amount of the provided token
                    * `1003`:  implicit payment methods cannot be modified
                    * `1004`:  payment method rejected by provider
                    * `provider:payment-method-rejected`:  payment method rejected by provider (identical to `1004`)
                    * `rule:product-denied`: Product restrictions forbid transaction, e.g., forbidden fuel type - token authorized only for Diesel but attempted to fuel Super.
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
                        * `1000`:  generic error
                        * `1001`:  payment processing temporarily unavailable
                        * `1002`:  requested amount exceeds the authorized amount of the provided token
                        * `1003`:  implicit payment methods cannot be modified
                        * `1004`:  payment method rejected by provider
                        * `provider:payment-method-rejected`:  payment method rejected by provider (identical to `1004`)
                        * `rule:product-denied`: Product restrictions forbid transaction, e.g., forbidden fuel type - token authorized only for Diesel but attempted to fuel Super.
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
                  guard let object = object as? Status401 else { return false }
                  guard self.errors == object.errors else { return false }
                  return true
                }

                public static func == (lhs: Status401, rhs: Status401) -> Bool {
                    return lhs.isEqual(to: rhs)
                }
            }

            /** Error objects provide additional information about problems encountered while performing an operation.
            Errors also contain codes besides title and message which can be used for checks even if the detailed messages might change.
                * `1000`:  generic error
                * `1001`:  payment processing temporarily unavailable
                * `1002`:  requested amount exceeds the authorized amount of the provided token
                * `1003`:  implicit payment methods cannot be modified
                * `1004`:  payment method rejected by provider
                * `provider:payment-method-rejected`:  payment method rejected by provider (identical to `1004`)
                * `rule:product-denied`: Product restrictions forbid transaction, e.g., forbidden fuel type - token authorized only for Diesel but attempted to fuel Super.
             */
            public class Status501: APIModel {

                public var errors: [Errors]?

                /** Error objects provide additional information about problems encountered while performing an operation.
                Errors also contain codes besides title and message which can be used for checks even if the detailed messages might change.
                    * `1000`:  generic error
                    * `1001`:  payment processing temporarily unavailable
                    * `1002`:  requested amount exceeds the authorized amount of the provided token
                    * `1003`:  implicit payment methods cannot be modified
                    * `1004`:  payment method rejected by provider
                    * `provider:payment-method-rejected`:  payment method rejected by provider (identical to `1004`)
                    * `rule:product-denied`: Product restrictions forbid transaction, e.g., forbidden fuel type - token authorized only for Diesel but attempted to fuel Super.
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
                        * `1000`:  generic error
                        * `1001`:  payment processing temporarily unavailable
                        * `1002`:  requested amount exceeds the authorized amount of the provided token
                        * `1003`:  implicit payment methods cannot be modified
                        * `1004`:  payment method rejected by provider
                        * `provider:payment-method-rejected`:  payment method rejected by provider (identical to `1004`)
                        * `rule:product-denied`: Product restrictions forbid transaction, e.g., forbidden fuel type - token authorized only for Diesel but attempted to fuel Super.
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
                  guard let object = object as? Status501 else { return false }
                  guard self.errors == object.errors else { return false }
                  return true
                }

                public static func == (lhs: Status501, rhs: Status501) -> Bool {
                    return lhs.isEqual(to: rhs)
                }
            }
            public typealias SuccessType = Void

            /** terms successfully updated */
            case status204

            /** OAuth token missing or invalid or a linked identity is missing.
Linked identity missing is a special case where you need to make sure that
the user has additionally logged in / authorized with a third-party.
This is not relevant for most use-cases.
The specific error code that identifies a missing linked identity is `missing-linked-identity`
Example:
```
  {
      "errors": [
          {
              "id": "cbgmhslmp1o9or9kh1p0",
              "title": "Missing linked identity for authorized access",
              "detail": "Linked identity is needed to access this resource, please check why the user does not have a linked identity",
              "status": "401",
              "code": "missing-linked-identity"
          }
      ]
  }
```
 */
            case status401(Status401)

            /** Internal server error */
            case status501(Status501)

            public var success: Void? {
                switch self {
                case .status204: return ()
                default: return nil
                }
            }

            public var response: Any {
                switch self {
                case .status401(let response): return response
                case .status501(let response): return response
                default: return ()
                }
            }

            public var statusCode: Int {
                switch self {
                case .status204: return 204
                case .status401: return 401
                case .status501: return 501
                }
            }

            public var successful: Bool {
                switch self {
                case .status204: return true
                case .status401: return false
                case .status501: return false
                }
            }

            public init(statusCode: Int, data: Data, decoder: ResponseDecoder) throws {
                switch statusCode {
                case 204: self = .status204
                case 401: self = try .status401(decoder.decode(Status401.self, from: data))
                case 501: self = try .status501(decoder.decode(Status501.self, from: data))
                default: throw APIClientError.unexpectedStatusCode(statusCode: statusCode, data: data)
                }
            }

            public var description: String {
                return "\(statusCode) \(successful ? "success" : "failure")"
            }

            public var debugDescription: String {
                var string = description
                let responseString = "\(response)"
                if responseString != "()" {
                    string += "\n\(responseString)"
                }
                return string
            }
        }
    }
}
