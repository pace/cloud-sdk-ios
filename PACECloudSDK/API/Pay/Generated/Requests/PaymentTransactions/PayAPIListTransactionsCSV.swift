//
// Generated by SwagGen
// https://github.com/pace/SwagGen
//

import Foundation

extension PayAPI.PaymentTransactions {

    /**
    List transactions as CSV

    List all transactions for the current user as csv.
    */
    public enum ListTransactionsCSV {

        public static var service = PayAPIService<Response>(id: "ListTransactionsCSV", tag: "Payment Transactions", method: "GET", path: "/transactions.csv", hasBody: false, securityRequirements: [SecurityRequirement(type: "OAuth2", scopes: ["pay:transactions:read"]), SecurityRequirement(type: "OIDC", scopes: ["pay:transactions:read"])])

        /** Sort by given attribute, plus and minus are used to indicate ascending and descending order. */
        public enum PCPaySort: String, Codable, Equatable, CaseIterable {
            case id = "id"
            case createdAt = "createdAt"
            case updatedAt = "updatedAt"
            case paymentMethodId = "paymentMethodId"
            case paymentMethodKind = "paymentMethodKind"
            case purposePRN = "purposePRN"
            case providerPRN = "providerPRN"
            case fuelProductName = "fuel.productName"
            case fuelType = "fuel.type"
            case idDescending = "-id"
            case createdAtDescending = "-createdAt"
            case updatedAtDescending = "-updatedAt"
            case paymentMethodIdDescending = "-paymentMethodId"
            case paymentMethodKindDescending = "-paymentMethodKind"
            case purposePRNDescending = "-purposePRN"
            case providerPRNDescending = "-providerPRN"
            case fuelProductNameDescending = "-fuel.productName"
            case fuelTypeDescending = "-fuel.type"
        }

        public final class Request: PayAPIRequest<Response> {

            public struct Options {

                /** Number of the page that should be returned (sometimes referred to as "offset"). Page `0` is the first page. */
                public var pagenumber: Int?

                /** Page size of the currently returned page (sometimes referred to as "limit"). */
                public var pagesize: Int?

                /** Sort by given attribute, plus and minus are used to indicate ascending and descending order. */
                public var sort: PCPaySort?

                /** ID of the payment transaction */
                public var filterid: String?

                /** Time the transaction was created. */
                public var filtercreatedAt: DateTime?

                /** Time the transaction was last updated. */
                public var filterupdatedAt: DateTime?

                /** Payment method ID of the transaction. */
                public var filterpaymentMethodId: ID?

                /** Payment method kind of the transaction. */
                public var filterpaymentMethodKind: String?

                /** PACE resource name of the resource, for which the payment was authorized. */
                public var filterpurposePRN: String?

                /** PACE resource name - referring to the transaction purpose with provider details. */
                public var filterproviderPRN: String?

                /** Product name of the fuel that was used in the transaction. */
                public var filterfuelProductName: String?

                /** Fuel type which was used in the transaction. */
                public var filterfuelType: String?

                public init(pagenumber: Int? = nil, pagesize: Int? = nil, sort: PCPaySort? = nil, filterid: String? = nil, filtercreatedAt: DateTime? = nil, filterupdatedAt: DateTime? = nil, filterpaymentMethodId: ID? = nil, filterpaymentMethodKind: String? = nil, filterpurposePRN: String? = nil, filterproviderPRN: String? = nil, filterfuelProductName: String? = nil, filterfuelType: String? = nil) {
                    self.pagenumber = pagenumber
                    self.pagesize = pagesize
                    self.sort = sort
                    self.filterid = filterid
                    self.filtercreatedAt = filtercreatedAt
                    self.filterupdatedAt = filterupdatedAt
                    self.filterpaymentMethodId = filterpaymentMethodId
                    self.filterpaymentMethodKind = filterpaymentMethodKind
                    self.filterpurposePRN = filterpurposePRN
                    self.filterproviderPRN = filterproviderPRN
                    self.filterfuelProductName = filterfuelProductName
                    self.filterfuelType = filterfuelType
                }
            }

            public var options: Options

            public init(options: Options) {
                self.options = options
                super.init(service: ListTransactionsCSV.service)
            }

            /// convenience initialiser so an Option doesn't have to be created
            public convenience init(pagenumber: Int? = nil, pagesize: Int? = nil, sort: PCPaySort? = nil, filterid: String? = nil, filtercreatedAt: DateTime? = nil, filterupdatedAt: DateTime? = nil, filterpaymentMethodId: ID? = nil, filterpaymentMethodKind: String? = nil, filterpurposePRN: String? = nil, filterproviderPRN: String? = nil, filterfuelProductName: String? = nil, filterfuelType: String? = nil) {
                let options = Options(pagenumber: pagenumber, pagesize: pagesize, sort: sort, filterid: filterid, filtercreatedAt: filtercreatedAt, filterupdatedAt: filterupdatedAt, filterpaymentMethodId: filterpaymentMethodId, filterpaymentMethodKind: filterpaymentMethodKind, filterpurposePRN: filterpurposePRN, filterproviderPRN: filterproviderPRN, filterfuelProductName: filterfuelProductName, filterfuelType: filterfuelType)
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
                if let sort = options.sort?.encode() {
                  params["sort"] = sort
                }
                if let filterid = options.filterid {
                  params["filter[id]"] = filterid
                }
                if let filtercreatedAt = options.filtercreatedAt?.encode() {
                  params["filter[createdAt]"] = filtercreatedAt
                }
                if let filterupdatedAt = options.filterupdatedAt?.encode() {
                  params["filter[updatedAt]"] = filterupdatedAt
                }
                if let filterpaymentMethodId = options.filterpaymentMethodId?.encode() {
                  params["filter[paymentMethodId]"] = filterpaymentMethodId
                }
                if let filterpaymentMethodKind = options.filterpaymentMethodKind {
                  params["filter[paymentMethodKind]"] = filterpaymentMethodKind
                }
                if let filterpurposePRN = options.filterpurposePRN {
                  params["filter[purposePRN]"] = filterpurposePRN
                }
                if let filterproviderPRN = options.filterproviderPRN {
                  params["filter[providerPRN]"] = filterproviderPRN
                }
                if let filterfuelProductName = options.filterfuelProductName {
                  params["filter[fuel.productName]"] = filterfuelProductName
                }
                if let filterfuelType = options.filterfuelType {
                  params["filter[fuel.type]"] = filterfuelType
                }
                return params
            }
        }

        public enum Response: APIResponseValue, CustomStringConvertible, CustomDebugStringConvertible {
            public typealias SuccessType = Void

            /** List of transactions */
            case status200

            /** Bad request */
            case status400(PCPayErrors)

            /** OAuth token missing or invalid */
            case status401(PCPayErrors)

            /** Resource not found */
            case status404(PCPayErrors)

            /** The specified accept header is invalid */
            case status406(PCPayErrors)

            /** Resource conflicts */
            case status409(PCPayErrors)

            /** The specified content type header is invalid */
            case status415(PCPayErrors)

            /** The request was well-formed but was unable to be followed due to semantic errors. */
            case status422(PCPayErrors)

            /** Internal server error */
            case status500(PCPayErrors)

            public var success: Void? {
                switch self {
                case .status200: return ()
                default: return nil
                }
            }

            public var failure: PCPayErrors? {
                switch self {
                case .status400(let response): return response
                case .status401(let response): return response
                case .status404(let response): return response
                case .status406(let response): return response
                case .status409(let response): return response
                case .status415(let response): return response
                case .status422(let response): return response
                case .status500(let response): return response
                default: return nil
                }
            }

            /// either success or failure value. Success is anything in the 200..<300 status code range
            public var responseResult: APIResponseResult<Void, PCPayErrors> {
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
                case .status400(let response): return response
                case .status401(let response): return response
                case .status404(let response): return response
                case .status406(let response): return response
                case .status409(let response): return response
                case .status415(let response): return response
                case .status422(let response): return response
                case .status500(let response): return response
                default: return ()
                }
            }

            public var statusCode: Int {
                switch self {
                case .status200: return 200
                case .status400: return 400
                case .status401: return 401
                case .status404: return 404
                case .status406: return 406
                case .status409: return 409
                case .status415: return 415
                case .status422: return 422
                case .status500: return 500
                }
            }

            public var successful: Bool {
                switch self {
                case .status200: return true
                case .status400: return false
                case .status401: return false
                case .status404: return false
                case .status406: return false
                case .status409: return false
                case .status415: return false
                case .status422: return false
                case .status500: return false
                }
            }

            public init(statusCode: Int, data: Data, decoder: ResponseDecoder) throws {
                switch statusCode {
                case 200: self = .status200
                case 400: self = try .status400(decoder.decode(PCPayErrors.self, from: data))
                case 401: self = try .status401(decoder.decode(PCPayErrors.self, from: data))
                case 404: self = try .status404(decoder.decode(PCPayErrors.self, from: data))
                case 406: self = try .status406(decoder.decode(PCPayErrors.self, from: data))
                case 409: self = try .status409(decoder.decode(PCPayErrors.self, from: data))
                case 415: self = try .status415(decoder.decode(PCPayErrors.self, from: data))
                case 422: self = try .status422(decoder.decode(PCPayErrors.self, from: data))
                case 500: self = try .status500(decoder.decode(PCPayErrors.self, from: data))
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