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

    private let cmsDispatchQueue: DispatchQueue = .init(label: "cms", qos: .utility)

    public init(baseURL: String, configuration: URLSessionConfiguration = .default) {
        self.baseURL = baseURL
        self.session = URLSession(configuration: configuration)
    }

    private func performRequest<T: Decodable>(with request: URLRequest, completion: @escaping (Result<T, APIClientError>) -> Void) {
        performDataTask(for: request) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let data):
                let decodedDataResult: Result<T, APIClientError> = self.decodeDataResponse(data: data)
                completion(decodedDataResult)

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    private func performDataTask(for request: URLRequest, completion: @escaping (Result<Data, APIClientError>) -> Void) {
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

            completion(.success(data))
        }.resume()
    }

    private func decodeDataResponse<T: Decodable>(data: Data) -> Result<T, APIClientError> {
        do {
            let jsonResult = try JSONDecoder().decode(T.self, from: data)
            return .success(jsonResult)
        } catch {
            return .failure(.unknownError(error))
        }
    }
}
