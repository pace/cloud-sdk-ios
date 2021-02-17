//
// Generated by SwagGen
// https://github.com/pace/SwagGen
//

import Foundation

public typealias AnyPOIAPIResponse = POIAPIResponse<AnyResponseValue>

public struct POIAPIResponse<T: APIResponseValue> {

    /// The Request used for this response
    public let request: POIAPIRequest<T>

    /// The result of the response .
    public let result: APIResult<T>

    /// The URL request sent to the server.
    public let urlRequest: URLRequest?

    /// The server's response to the URL request.
    public let urlResponse: HTTPURLResponse?

    /// The data returned by the server.
    public let data: Data?

    init(request: POIAPIRequest<T>, result: APIResult<T>, urlRequest: URLRequest? = nil, urlResponse: HTTPURLResponse? = nil, data: Data? = nil) {
        self.request = request
        self.result = result
        self.urlRequest = urlRequest
        self.urlResponse = urlResponse
        self.data = data
    }
}

extension POIAPIResponse: CustomStringConvertible, CustomDebugStringConvertible {

    public var description:String {
        var string = "\(request)"

        switch result {
        case .success(let value):
            string += " returned \(value.statusCode)"
            let responseString = "\(type(of: value.response))"
            if responseString != "()" {
                string += ": \(responseString)"
            }
        case .failure(let error): string += " failed: \(error)"
        }
        return string
    }

    public var debugDescription: String {
        var string = description
        if let response = try? result.get().response {
          if let debugStringConvertible = response as? CustomDebugStringConvertible {
              string += "\n\(debugStringConvertible.debugDescription)"
          }
        }
        return string
    }
}

extension POIAPIResponse {
    public func asAny() -> POIAPIResponse<AnyResponseValue> {
        return POIAPIResponse<AnyResponseValue>(request: request.asAny(), result: result.map{ $0.asAny() }, urlRequest: urlRequest, urlResponse: urlResponse, data: data)
    }
}