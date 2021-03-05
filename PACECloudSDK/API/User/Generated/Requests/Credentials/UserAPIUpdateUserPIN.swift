//
// Generated by SwagGen
// https://github.com/pace/SwagGen
//

import Foundation

extension UserAPI.Credentials {

    /**
    Set the new PIN

    Sets the PIN of the user. The user has to select a secure PIN, this is ensured via rules. If one of the rules fails `406` is returned. To set the PIN an account OTP needs to be provided.
The following rules apply to verify the PIN:
* must be 4 digits long
* must use 3 different digits
* must not be a numerical series (e.g. 1234, 4321, ...)
    */
    public enum UpdateUserPIN {

        public static var service = UserAPIService<Response>(id: "UpdateUserPIN", tag: "Credentials", method: "PUT", path: "/user/pin", hasBody: true, securityRequirements: [SecurityRequirement(type: "OAuth2", scopes: ["user:users.pin:update"]), SecurityRequirement(type: "OIDC", scopes: ["user:users.pin:update"])])

        public final class Request: UserAPIRequest<Response> {

            /** Sets the PIN of the user. The user has to select a secure PIN, this is ensured via rules. If one of the rules fails `406` is returned. To set the PIN an account OTP needs to be provided.
            The following rules apply to verify the PIN:
            * must be 4 digits long
            * must use 3 different digits
            * must not be a numerical series (e.g. 1234, 4321, ...)
             */
            public class Body: APIModel {

                public var data: PCUserUserPIN?

                public init(data: PCUserUserPIN? = nil) {
                    self.data = data
                }

                public required init(from decoder: Decoder) throws {
                    let container = try decoder.container(keyedBy: StringCodingKey.self)

                    data = try container.decodeIfPresent("data")
                }

                public func encode(to encoder: Encoder) throws {
                    var container = encoder.container(keyedBy: StringCodingKey.self)

                    try container.encodeIfPresent(data, forKey: "data")
                }

                public func isEqual(to object: Any?) -> Bool {
                  guard let object = object as? Body else { return false }
                  guard self.data == object.data else { return false }
                  return true
                }

                public static func == (lhs: Body, rhs: Body) -> Bool {
                    return lhs.isEqual(to: rhs)
                }
            }

            public var body: Body

            public init(body: Body, encoder: RequestEncoder? = nil) {
                self.body = body
                super.init(service: UpdateUserPIN.service) { defaultEncoder in
                    return try (encoder ?? defaultEncoder).encode(body)
                }
                self.contentType = "application/vnd.api+json"
            }
        }

        public enum Response: APIResponseValue, CustomStringConvertible, CustomDebugStringConvertible {

            /** Error objects provide additional information about problems encountered while performing an operation.
            Errors also contain codes besides title and message which can be used for checks even if the detailed messages might change.
                * code `1000`:  generic error
                * code `1001`:  payment processing temporarily unavailable
                * code `1002`:  requested amount exceeds the authorized amount of the provided token
                * code `1003`:  implicit payment methods cannot be modified
                * code `1004`:  payment method rejected by provider
             */
            public class Status401: APIModel {

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
                * code `1000`:  generic error
                * code `1001`:  payment processing temporarily unavailable
                * code `1002`:  requested amount exceeds the authorized amount of the provided token
                * code `1003`:  implicit payment methods cannot be modified
                * code `1004`:  payment method rejected by provider
             */
            public class Status403: APIModel {

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
                  guard let object = object as? Status403 else { return false }
                  guard self.errors == object.errors else { return false }
                  return true
                }

                public static func == (lhs: Status403, rhs: Status403) -> Bool {
                    return lhs.isEqual(to: rhs)
                }
            }

            /** Error objects provide additional information about problems encountered while performing an operation.
            Errors also contain codes besides title and message which can be used for checks even if the detailed messages might change.
                * code `1000`:  generic error
                * code `1001`:  payment processing temporarily unavailable
                * code `1002`:  requested amount exceeds the authorized amount of the provided token
                * code `1003`:  implicit payment methods cannot be modified
                * code `1004`:  payment method rejected by provider
             */
            public class Status501: APIModel {

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
                  guard let object = object as? Status501 else { return false }
                  guard self.errors == object.errors else { return false }
                  return true
                }

                public static func == (lhs: Status501, rhs: Status501) -> Bool {
                    return lhs.isEqual(to: rhs)
                }
            }
            public typealias SuccessType = Void

            /** PIN updated */
            case status200

            /** OAuth token missing or invalid */
            case status401(Status401)

            /** Forbidden */
            case status403(Status403)

            /** PIN not secure */
            case status406(PCUserErrors)

            /** Internal server error */
            case status501(Status501)

            public var success: Void? {
                switch self {
                case .status200: return ()
                default: return nil
                }
            }

            public var response: Any {
                switch self {
                case .status401(let response): return response
                case .status403(let response): return response
                case .status406(let response): return response
                case .status501(let response): return response
                default: return ()
                }
            }

            public var statusCode: Int {
                switch self {
                case .status200: return 200
                case .status401: return 401
                case .status403: return 403
                case .status406: return 406
                case .status501: return 501
                }
            }

            public var successful: Bool {
                switch self {
                case .status200: return true
                case .status401: return false
                case .status403: return false
                case .status406: return false
                case .status501: return false
                }
            }

            public init(statusCode: Int, data: Data, decoder: ResponseDecoder) throws {
                switch statusCode {
                case 200: self = .status200
                case 401: self = try .status401(decoder.decode(Status401.self, from: data))
                case 403: self = try .status403(decoder.decode(Status403.self, from: data))
                case 406: self = try .status406(decoder.decode(PCUserErrors.self, from: data))
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
