//
// Generated by SwagGen
// https://github.com/pace/SwagGen
//

import Foundation

extension POIAPI.DataDumps {

    /**
    Duplicate Map for country (KML)

    Generates a map of potential gas station duplicates (closer than 50m to eachother) for specified country.
    */
    public enum GetDuplicatesKML {

        public static var service = POIAPIService<Response>(id: "GetDuplicatesKML", tag: "Data Dumps", method: "GET", path: "/datadumps/duplicatemap/{countryCode}", hasBody: false, securityRequirements: [SecurityRequirement(type: "OAuth2", scopes: ["poi:dumps:duplicatemap"]), SecurityRequirement(type: "OIDC", scopes: ["poi:dumps:duplicatemap"])])

        public final class Request: POIAPIRequest<Response> {

            public struct Options {

                /** Country code in ISO 3166-1 alpha-2 format */
                public var countryCode: String?

                public init(countryCode: String? = nil) {
                    self.countryCode = countryCode
                }
            }

            public var options: Options

            public init(options: Options) {
                self.options = options
                super.init(service: GetDuplicatesKML.service)
            }

            /// convenience initialiser so an Option doesn't have to be created
            public convenience init(countryCode: String? = nil) {
                let options = Options(countryCode: countryCode)
                self.init(options: options)
            }

            public override var path: String {
                return super.path.replacingOccurrences(of: "{" + "countryCode" + "}", with: "\(self.options.countryCode ?? "")")
            }
        }

        public enum Response: APIResponseValue, CustomStringConvertible, CustomDebugStringConvertible {
            public typealias SuccessType = File

            /** OK */
            case status200(File)

            /** OAuth token missing or invalid */
            case status401(PCPOIErrors)

            /** Resource not found */
            case status404(PCPOIErrors)

            /** Internal server error */
            case status500(PCPOIErrors)

            public var success: File? {
                switch self {
                case .status200(let response): return response
                default: return nil
                }
            }

            public var failure: PCPOIErrors? {
                switch self {
                case .status401(let response): return response
                case .status404(let response): return response
                case .status500(let response): return response
                default: return nil
                }
            }

            /// either success or failure value. Success is anything in the 200..<300 status code range
            public var responseResult: APIResponseResult<File, PCPOIErrors> {
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
                case .status401(let response): return response
                case .status404(let response): return response
                case .status500(let response): return response
                }
            }

            public var statusCode: Int {
                switch self {
                case .status200: return 200
                case .status401: return 401
                case .status404: return 404
                case .status500: return 500
                }
            }

            public var successful: Bool {
                switch self {
                case .status200: return true
                case .status401: return false
                case .status404: return false
                case .status500: return false
                }
            }

            public init(statusCode: Int, data: Data, decoder: ResponseDecoder) throws {
                switch statusCode {
                case 200: self = try .status200(data)
                case 401: self = try .status401(decoder.decode(PCPOIErrors.self, from: data))
                case 404: self = try .status404(decoder.decode(PCPOIErrors.self, from: data))
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