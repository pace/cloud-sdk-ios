//
//  CmsAPIClient.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

/// Manages and sends APIRequests
public class CmsAPIClient {

    public static var `default` = CmsAPIClient(baseURL: "https://api.pace.cloud/cms")

    /// The base url prepended before every request path
    public var baseURL: String

    /// The UrlSession used for each request
    public var session: URLSession

    /// These headers will get added to every request
    public var defaultHeaders: [String: String] = [:]

    public init(baseURL: String, configuration: URLSessionConfiguration = .default) {
        self.baseURL = baseURL
        self.session = URLSession(configuration: configuration)
    }

    public func paymentMethodVendors(completion: @escaping (Result<[PaymentMethodVendor], APIClientError>) -> Void) {
        guard let url = URL(string: "\(baseURL)/payment-method-vendors") else {
            completion(.failure(.requestEncodingError(APIRequestError.encodingURL)))
            return
        }

        let request = URLRequest(url: url)
        performRequest(with: request, completion: completion)
    }

    private func performRequest<T: Decodable>(with request: URLRequest, completion: @escaping (Result<T, APIClientError>) -> Void) {
        var requestWithHeaders = request

        for (key, value) in defaultHeaders {
            requestWithHeaders.setValue(value, forHTTPHeaderField: key)
        }

        self.session.dataTask(with: requestWithHeaders) { data, response, error -> Void in
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }

            guard let response = response as? HTTPURLResponse,
                  let data = data else {
                completion(.failure(.networkError(URLRequestError.responseInvalid)))
                return
            }

            guard response.statusCode < HttpStatusCode.badRequest.rawValue else {
                completion(.failure(.unexpectedStatusCode(statusCode: response.statusCode, data: data)))
                return
            }

            do {
                let jsonResult = try JSONDecoder().decode(T.self, from: data)
                completion(.success(jsonResult))
            } catch {
                completion(.failure(.unknownError(error)))
            }

        }.resume()
    }
}
