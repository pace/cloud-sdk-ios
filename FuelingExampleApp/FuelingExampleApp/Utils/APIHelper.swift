//
//  APIHelper.swift
//  FuelingExampleApp
//
//  Created by PACE Telematics GmbH.
//

import Foundation
import PACECloudSDK

enum APIHelper {
    static func discountRequest(gasStationId: String,
                                pumpId: String,
                                paymentMethodId: String?,
                                paymentMethodKind: String?) -> URLRequest? {
        let discountRequestBody = DiscountRequest(data: .init(attributes: .init(paymentMethodId: paymentMethodId, paymentMethodKind: paymentMethodKind)))

        guard let discountUrl = URL(string: Constants.apiBaseURL + "/fueling/master/gas-stations/\(gasStationId)/pumps/\(pumpId)/discounts"),
              let encodedRequestBody = try? JSONEncoder().encode(discountRequestBody) else {
                  NSLog("[APIManager] Failed requesting discount: Failed encoding request body.")
                  return nil
              }

        var urlRequest = URLRequest(url: discountUrl)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = encodedRequestBody

        [
            HttpHeaderFields.accept.rawValue: "application/vnd.api+json",
            HttpHeaderFields.contentType.rawValue: "application/vnd.api+json",
            HttpHeaderFields.authorization.rawValue: "Bearer \(API.accessToken ?? "")"
        ].forEach {
            urlRequest.setValue($0.value, forHTTPHeaderField: $0.key)
        }

        return urlRequest
    }

    static func makeCustomJSONRequest<T: Decodable>(_ request: URLRequest,
                                                    session: URLSession = .shared,
                                                    decoder: JSONDecoder = JSONDecoder(),
                                                    completion: @escaping (Result<T, APIClientError>) -> Void) -> URLSessionDataTask {
        return performRequest(request, session: session) { result in
            switch result {
            case .success(let data):
                do {
                    let result = try decoder.decode(T.self, from: data)
                    completion(.success(result))
                } catch {
                    NSLog("[APIHelper] Failed request \(request.url?.absoluteString ?? "invalid url") with error \(error)")
                    completion(.failure(.unknownError(error)))
                }

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    private static func performRequest(_ request: URLRequest, session: URLSession = .shared, completion: @escaping (Result<Data, APIClientError>) -> Void) -> URLSessionDataTask {
        let dataTask = session.dataTask(with: request) { data, response, error in
            if let error = error {
                NSLog("[APIHelper] Failed request \(request.url?.absoluteString ?? "invalid url") with error \(error).")

                if (error as NSError?)?.code == NSURLErrorCancelled {
                    completion(.failure(.networkError(error)))
                    return
                }
                completion(.failure(.unknownError(error)))
                return
            }

            guard let response = response as? HTTPURLResponse else {
                NSLog("[APIHelper] Failed request \(request.url?.absoluteString ?? "invalid url") due to invalid response.")
                completion(.failure(.invalidDataError))
                return
            }

            let statusCode = response.statusCode

            guard statusCode < 400 else {
                NSLog("[APIHelper] Failed request \(request.url?.absoluteString ?? "invalid url") with status code \(statusCode)")
                completion(.failure(.invalidDataError))
                return
            }

            guard let data = data else {
                NSLog("[APIHelper] Failed request \(request.url?.absoluteString ?? "invalid url") due to invalid data")
                completion(.failure(.invalidDataError))
                return
            }

            completion(.success(data))
        }
        dataTask.resume()
        return dataTask
    }
}

extension APIHelper {
    static func retrieveRequestID(from response: HTTPURLResponse?) -> String {
        response?.value(forHTTPHeaderField: "request-id") ?? "unknown"
    }

    @discardableResult
    static func makeFuelingRequest<T: APIResponseValue>(_ request: FuelingAPIRequest<T>, completion: @escaping (FuelingAPIResponse<T>) -> Void) -> CancellableFuelingAPIRequest? {
        request.contentType = "application/vnd.api+json"
        return API.Fueling.client.makeRequest(request, complete: completion)
    }

    @discardableResult
    static func makePayRequest<T: APIResponseValue>(_ request: PayAPIRequest<T>, completion: @escaping (PayAPIResponse<T>) -> Void) -> CancellablePayAPIRequest? {
        return API.Pay.client.makeRequest(request, complete: completion)
    }
}
