//
// Generated by SwagGen
// https://github.com/pace/SwagGen
//

import Foundation

extension POIAPI.GasStations {

    /**
    Query for gas stations

    There are two ways to search for gas stations in a geo location. You can use either one, or none, but not both ways.
To search inside a specific radius around a given longitude and latitude provide the following query parameters:
* latitude
* longitude
* radius
To search inside a bounding box provide the following query parameter:
* boundingBox
    */
    public enum GetGasStations {

        public static var service = POIAPIService<Response>(id: "GetGasStations", tag: "Gas Stations", method: "GET", path: "/gas-stations", hasBody: false, securityRequirements: [SecurityRequirement(type: "OAuth2", scopes: ["poi:gas-stations:read", "poi:gas-stations.references:read"]), SecurityRequirement(type: "OIDC", scopes: ["poi:gas-stations:read", "poi:gas-stations.references:read"])])

        /** POI type you are searching for (in this case gas stations) */
        public enum PCPOIFilterpoiType: String, Codable, Equatable, CaseIterable {
            case gasStation = "gasStation"
        }

        /** Search only gas stations with fueling app available */
        public enum PCPOIFilterappType: String, Codable, Equatable, CaseIterable {
            case fueling = "fueling"
        }

        public final class Request: POIAPIRequest<Response> {

            public struct Options {

                /** page number */
                public var pagenumber: Int?

                /** items per page */
                public var pagesize: Int?

                /** POI type you are searching for (in this case gas stations) */
                public var filterpoiType: PCPOIFilterpoiType?

                /** Search only gas stations with fueling app available */
                public var filterappType: [PCPOIFilterappType]?

                /** Latitude in degrees */
                public var filterlatitude: Float?

                /** Longitude in degrees */
                public var filterlongitude: Float?

                /** Radius in meters */
                public var filterradius: Float?

                /** Bounding box representing left, bottom, right, top in degrees. The query parameters need to be passed 4 times in exactly the order left, bottom, right, top.
<table> <tr><th>#</th><th>Value</th><th>Lat/Long</th><th>Range</th></tr> <tr><td>0</td><td>left</td><td>Lat</td><td>[-180..180]</td></tr> <tr><td>1</td><td>bottom</td><td>Long</td><td>[-90..90]</td></tr> <tr><td>2</td><td>right</td><td>Lat</td><td>[-180..180]</td></tr> <tr><td>3</td><td>top</td><td>Long</td><td>[-90..90]</td></tr> </table>
 */
                public var filterboundingBox: [Float]?

                /** Reduces the opening hours rules. After compilation only rules with the action open will remain in the response. */
                public var compileopeningHours: Bool?

                /** Filter by source ID */
                public var filtersource: ID?

                public init(pagenumber: Int? = nil, pagesize: Int? = nil, filterpoiType: PCPOIFilterpoiType? = nil, filterappType: [PCPOIFilterappType]? = nil, filterlatitude: Float? = nil, filterlongitude: Float? = nil, filterradius: Float? = nil, filterboundingBox: [Float]? = nil, compileopeningHours: Bool? = nil, filtersource: ID? = nil) {
                    self.pagenumber = pagenumber
                    self.pagesize = pagesize
                    self.filterpoiType = filterpoiType
                    self.filterappType = filterappType
                    self.filterlatitude = filterlatitude
                    self.filterlongitude = filterlongitude
                    self.filterradius = filterradius
                    self.filterboundingBox = filterboundingBox
                    self.compileopeningHours = compileopeningHours
                    self.filtersource = filtersource
                }
            }

            public var options: Options

            public init(options: Options) {
                self.options = options
                super.init(service: GetGasStations.service)
            }

            /// convenience initialiser so an Option doesn't have to be created
            public convenience init(pagenumber: Int? = nil, pagesize: Int? = nil, filterpoiType: PCPOIFilterpoiType? = nil, filterappType: [PCPOIFilterappType]? = nil, filterlatitude: Float? = nil, filterlongitude: Float? = nil, filterradius: Float? = nil, filterboundingBox: [Float]? = nil, compileopeningHours: Bool? = nil, filtersource: ID? = nil) {
                let options = Options(pagenumber: pagenumber, pagesize: pagesize, filterpoiType: filterpoiType, filterappType: filterappType, filterlatitude: filterlatitude, filterlongitude: filterlongitude, filterradius: filterradius, filterboundingBox: filterboundingBox, compileopeningHours: compileopeningHours, filtersource: filtersource)
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
                if let filterappType = options.filterappType?.encode().map({ String(describing: $0) }).joined(separator: ",") {
                  params["filter[appType]"] = filterappType
                }
                if let filterlatitude = options.filterlatitude {
                  params["filter[latitude]"] = filterlatitude
                }
                if let filterlongitude = options.filterlongitude {
                  params["filter[longitude]"] = filterlongitude
                }
                if let filterradius = options.filterradius {
                  params["filter[radius]"] = filterradius
                }
                if let filterboundingBox = options.filterboundingBox?.map({ String(describing: $0) }).joined(separator: ",") {
                  params["filter[boundingBox]"] = filterboundingBox
                }
                if let compileopeningHours = options.compileopeningHours {
                  params["compile[openingHours]"] = compileopeningHours
                }
                if let filtersource = options.filtersource?.encode() {
                  params["filter[source]"] = filtersource
                }
                return params
            }
        }

        public enum Response: APIResponseValue, CustomStringConvertible, CustomDebugStringConvertible {

            /** There are two ways to search for gas stations in a geo location. You can use either one, or none, but not both ways.
            To search inside a specific radius around a given longitude and latitude provide the following query parameters:
            * latitude
            * longitude
            * radius
            To search inside a bounding box provide the following query parameter:
            * boundingBox
             */
            public class Status200: APIModel {

                public var data: PCPOIGasStations?

                public var included: [Poly3<PCPOIFuelPrice,PCPOILocationBasedApp,PCPOIReferenceStatus>]?

                public init(data: PCPOIGasStations? = nil, included: [Poly3<PCPOIFuelPrice,PCPOILocationBasedApp,PCPOIReferenceStatus>]? = nil) {
                    self.data = data
                    self.included = included
                }

                public required init(from decoder: Decoder) throws {
                    let container = try decoder.container(keyedBy: StringCodingKey.self)

                    data = try container.decodeIfPresent("data")
                    included = try container.decodeArrayIfPresent("included")
                }

                public func encode(to encoder: Encoder) throws {
                    var container = encoder.container(keyedBy: StringCodingKey.self)

                    try container.encodeIfPresent(data, forKey: "data")
                    try container.encodeIfPresent(included, forKey: "included")
                }

                public func isEqual(to object: Any?) -> Bool {
                  guard let object = object as? Status200 else { return false }
                  guard self.data == object.data else { return false }
                  guard self.included == object.included else { return false }
                  return true
                }

                public static func == (lhs: Status200, rhs: Status200) -> Bool {
                    return lhs.isEqual(to: rhs)
                }
            }
            public typealias SuccessType = Status200

            /** OK */
            case status200(Status200)

            /** Bad request */
            case status400(PCPOIErrors)

            /** OAuth token missing or invalid */
            case status401(PCPOIErrors)

            /** The specified accept header is invalid */
            case status406(PCPOIErrors)

            /** Internal server error */
            case status500(PCPOIErrors)

            public var success: Status200? {
                switch self {
                case .status200(let response): return response
                default: return nil
                }
            }

            public var failure: PCPOIErrors? {
                switch self {
                case .status400(let response): return response
                case .status401(let response): return response
                case .status406(let response): return response
                case .status500(let response): return response
                default: return nil
                }
            }

            /// either success or failure value. Success is anything in the 200..<300 status code range
            public var responseResult: APIResponseResult<Status200, PCPOIErrors> {
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
                case 400: self = try .status400(decoder.decode(PCPOIErrors.self, from: data))
                case 401: self = try .status401(decoder.decode(PCPOIErrors.self, from: data))
                case 406: self = try .status406(decoder.decode(PCPOIErrors.self, from: data))
                case 500: self = try .status500(decoder.decode(PCPOIErrors.self, from: data))
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