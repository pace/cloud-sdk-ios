//
//  URLDataRequest.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

struct URLDataRequest {

    // Default cache disabled
    private static var defaultURLSession: URLSession {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadRevalidatingCacheData
        config.httpAdditionalHeaders = AppKitConstants.userAgentHeader

        return URLSession(configuration: config)
    }

    static func requestJson<T: Decodable>(with urlString: String,
                                          expectedType: T.Type,
                                          headers: [String: String]?,
                                          completion: @escaping ((Swift.Result<T, URLRequestError>) -> Void)) where T: AnyObject {

        request(with: urlString, headers: headers) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))

            case .success(let data):
                if let json = retrieveJson(from: data, expectedType: expectedType) {
                    completion(.success(json))
                } else {
                    completion(.failure(.failedParsingJson))
                }
            }
        }
    }

    static func requestData(with urlString: String, headers: [String: String]?, completion: @escaping ((Swift.Result<Data, URLRequestError>) -> Void)) {
        request(with: urlString, headers: headers, completion: completion)
    }

    private static func request(with urlString: String, headers: [String: String]?, completion: @escaping ((Swift.Result<Data, URLRequestError>) -> Void)) {
        guard let request = URLRequestBuilder.buildRequest(with: urlString, additionalHeaders: headers) else {
            completion(.failure(.failedRetrievingUrlRequest(urlString)))
            return
        }

        defaultURLSession.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.other(error)))
                return
            }

            guard let response = response as? HTTPURLResponse else {
                completion(.failure(.responseInvalid))
                return
            }

            let statusCode = response.statusCode
            AppKitLogger.i("[UrlDataRequest] Received response with status code \(statusCode) for url \(urlString)")

            guard statusCode < 400 else {
                completion(.failure(.httpStatusCodeError))
                return
            }

            guard let data = data else {
                completion(.failure(.urlRequestDataError))
                return
            }

            completion(.success(data))
        }.resume()
    }

    private static func retrieveJson<T: Decodable>(from data: Data, expectedType: T.Type) -> T? where T: AnyObject {
        do {
            return try JSONDecoder().decode(expectedType, from: data)
        } catch {
            AppKitLogger.e("[URLDataRequest] Failed parsing json with error \(error.localizedDescription)")
            return nil
        }
    }
}
