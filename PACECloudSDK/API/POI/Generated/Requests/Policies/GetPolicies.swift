//
// Generated by SwagGen
// https://github.com/pace/SwagGen
//

import Foundation

extension POIAPI.Policies {

    /**
    Returns a paginated list of policies

    Returns a paginated list of policies optionally filtered by poi type and/or country id and/or user id
    */
    public enum GetPolicies {

        public static let service = APIService<Response>(id: "GetPolicies", tag: "Policies", method: "GET", path: "/beta/policies", hasBody: false, securityRequirements: [SecurityRequirement(type: "OAuth2", scopes: ["poi:policies:read"]), SecurityRequirement(type: "OIDC", scopes: ["poi:policies:read"])])

        public final class Request: APIRequest<Response> {

            public struct Options {

                /** page number */
                public var pagenumber: Int?

                /** items per page */
                public var pagesize: Int?

                /** Filter for poi type, no filter returns all types */
                public var filterpoiType: PCPOIType?

                /** Filter for all policies for the given country */
                public var filtercountryId: String?

                /** Filter for all policies created by the given user */
                public var filteruserId: ID?

                public init(pagenumber: Int? = nil, pagesize: Int? = nil, filterpoiType: PCPOIType? = nil, filtercountryId: String? = nil, filteruserId: ID? = nil) {
                    self.pagenumber = pagenumber
                    self.pagesize = pagesize
                    self.filterpoiType = filterpoiType
                    self.filtercountryId = filtercountryId
                    self.filteruserId = filteruserId
                }
            }

            public var options: Options

            public init(options: Options) {
                self.options = options
                super.init(service: GetPolicies.service)
            }

            /// convenience initialiser so an Option doesn't have to be created
            public convenience init(pagenumber: Int? = nil, pagesize: Int? = nil, filterpoiType: PCPOIType? = nil, filtercountryId: String? = nil, filteruserId: ID? = nil) {
                let options = Options(pagenumber: pagenumber, pagesize: pagesize, filterpoiType: filterpoiType, filtercountryId: filtercountryId, filteruserId: filteruserId)
                self.init(options: options)
            }

            public override var queryParameters: [String: Any] {
                var params: [String: Any] = [:]
                if let pagenumber = options.pagenumber {
                  params["page[number]"] = pagenumber
                }
                if let pagesize = options.pagesize {
                  params["page[size]"] = pagesize
                }
                if let filterpoiType = options.filterpoiType?.encode() {
                  params["filter[poiType]"] = filterpoiType
                }
                if let filtercountryId = options.filtercountryId {
                  params["filter[countryId]"] = filtercountryId
                }
                if let filteruserId = options.filteruserId?.encode() {
                  params["filter[userId]"] = filteruserId
                }
                return params
            }
        }

        public enum Response: APIResponseValue, CustomStringConvertible, CustomDebugStringConvertible {

            /** Returns a paginated list of policies optionally filtered by poi type and/or country id and/or user id */
            public class Status200: APIModel {

                public var data: PCPolicies?

                public init(data: PCPolicies? = nil) {
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
                  guard let object = object as? Status200 else { return false }
                  guard self.data == object.data else { return false }
                  return true
                }

                public static func == (lhs: Status200, rhs: Status200) -> Bool {
                    return lhs.isEqual(to: rhs)
                }
            }
            public typealias SuccessType = Status200

            /** OK */
            case status200(Status200)

            /** The server cannot or will not process the request due to an apparent client error
 */
            case status400(PCErrors)

            /** OAuth token missing or invalid */
            case status401(PCErrors)

            /** The specified Accept header is not valid */
            case status406(PCErrors)

            /** A generic error message, given when an unexpected condition was encountered and no more specific message is suitable. */
            case status500(PCErrors)

            public var success: Status200? {
                switch self {
                case .status200(let response): return response
                default: return nil
                }
            }

            public var failure: PCErrors? {
                switch self {
                case .status400(let response): return response
                case .status401(let response): return response
                case .status406(let response): return response
                case .status500(let response): return response
                default: return nil
                }
            }

            /// either success or failure value. Success is anything in the 200..<300 status code range
            public var responseResult: APIResponseResult<Status200, PCErrors> {
                if let successValue = success {
                    return .success(successValue)
                } else if let failureValue = failure {
                    return .failure(failureValue)
                } else {
                    fatalError("Response does not have success or failure response")
                }
            }

            public var response: Any {
                switch self {
                case .status200(let response): return response
                case .status400(let response): return response
                case .status401(let response): return response
                case .status406(let response): return response
                case .status500(let response): return response
                }
            }

            public var statusCode: Int {
                switch self {
                case .status200: return 200
                case .status400: return 400
                case .status401: return 401
                case .status406: return 406
                case .status500: return 500
                }
            }

            public var successful: Bool {
                switch self {
                case .status200: return true
                case .status400: return false
                case .status401: return false
                case .status406: return false
                case .status500: return false
                }
            }

            public init(statusCode: Int, data: Data, decoder: ResponseDecoder) throws {
                switch statusCode {
                case 200: self = try .status200(decoder.decode(Status200.self, from: data))
                case 400: self = try .status400(decoder.decode(PCErrors.self, from: data))
                case 401: self = try .status401(decoder.decode(PCErrors.self, from: data))
                case 406: self = try .status406(decoder.decode(PCErrors.self, from: data))
                case 500: self = try .status500(decoder.decode(PCErrors.self, from: data))
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
