//
//  CustomAPIClient.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

public class CustomAPIClient {
    /// The UrlSession used for each request
    public var session: URLSession

    /// These headers will get added to every request
    public var defaultHeaders: [String: String] = [:]

    public var decodingQueue = DispatchQueue(label: "CustomAPIClient", qos: .utility, attributes: .concurrent)

    /// The maximum number a request will be retried due to `401` responses
    public var maxUnauthorizedRetryCount = 1

    /// The maximum number a request will be retried due to network connection errors and timeouts
    public var maxRetryCount = 8

    public init(configuration: URLSessionConfiguration = .default) {
        self.session = URLSession(configuration: configuration)
    }

    @discardableResult
    public func makeCustomJSONRequest<T: Decodable>(_ request: URLRequest,
                                                    session: URLSession = .shared,
                                                    decoder: JSONDecoder = JSONDecoder(),
                                                    currentUnauthorizedRetryCount: Int = 0,
                                                    currentRetryCount: Int = 0,
                                                    completionQueue: DispatchQueue = .main,
                                                    completion: @escaping (Result<T, APIClientError>) -> Void) -> URLSessionDataTask {
        return makeNetworkRequest(request: request,
                                  session: session,
                                  currentUnauthorizedRetryCount: currentUnauthorizedRetryCount,
                                  currentRetryCount: currentRetryCount) { [weak self] result in
            guard let self = self else { return }

            let result: Result<T, APIClientError> = self.decodeCustomJSONResult(result,
                                                                                request: request,
                                                                                decoder: decoder)
            completionQueue.async {
                completion(result)
            }
        }
    }

    @discardableResult
    public func makeCustomDataRequest(_ request: URLRequest,
                                      session: URLSession = .shared,
                                      currentUnauthorizedRetryCount: Int = 0,
                                      currentRetryCount: Int = 0,
                                      completionQueue: DispatchQueue = .main,
                                      completion: @escaping (Result<Data, APIClientError>) -> Void) -> URLSessionDataTask {
        return makeNetworkRequest(request: request,
                                  session: session,
                                  currentUnauthorizedRetryCount: currentUnauthorizedRetryCount,
                                  currentRetryCount: currentRetryCount) { result in
            completionQueue.async {
                completion(result)
            }
        }
    }

    private func makeNetworkRequest(request: URLRequest,
                                    session: URLSession = .shared,
                                    currentUnauthorizedRetryCount: Int,
                                    currentRetryCount: Int,
                                    completion: @escaping (Result<Data, APIClientError>) -> Void) -> URLSessionDataTask {
        let maxRetryCount = maxRetryCount
        let modifiedRequest = modify(request: request)

        let dataTask = session.dataTask(with: modifiedRequest) { [weak self] data, response, error in
            self?.decodingQueue.async {
                let newRetryCount = currentRetryCount + 1
                if API.shouldRetryRequest(currentRetryCount: newRetryCount,
                                          maxRetryCount: maxRetryCount,
                                          response: response) {
                    let requestDelay = API.nextExponentialBackoffRequestDelay(currentRetryCount: newRetryCount)
                    self?.decodingQueue.asyncAfter(deadline: .now() + .seconds(requestDelay)) { [weak self] in
                        _ = self?.makeNetworkRequest(request: modifiedRequest,
                                                     session: session,
                                                     currentUnauthorizedRetryCount: currentUnauthorizedRetryCount,
                                                     currentRetryCount: newRetryCount,
                                                     completion: completion)
                    }
                } else if let response = response as? HTTPURLResponse {
                    self?.handleResponse(request: modifiedRequest,
                                         data: data,
                                         response: response,
                                         error: error,
                                         currentUnauthorizedRetryCount: currentUnauthorizedRetryCount,
                                         currentRetryCount: currentRetryCount,
                                         completion: completion)
                } else {
                    var apiError: APIClientError
                    if let error = error {
                        apiError = APIClientError.networkError(error)
                    } else {
                        apiError = APIClientError.networkError(URLRequestError.responseInvalid)
                    }

                    completion(.failure(apiError))
                }
            }
        }

        decodingQueue.async {
            dataTask.resume()
        }

        return dataTask
    }

    // swiftlint:disable:next function_parameter_count
    private func handleResponse(request: URLRequest,
                                data: Data?,
                                response: HTTPURLResponse,
                                error: Error?,
                                currentUnauthorizedRetryCount: Int,
                                currentRetryCount: Int,
                                completion: @escaping (Result<Data, APIClientError>) -> Void) {
        let urlString = request.url?.absoluteString ?? "invalid url"

        if let error = error {
            SDKLogger.e("[CustomAPIClient] Failed request \(urlString) with error \(error).")
            let apiError = APIClientError.networkError(error)
            completion(.failure(apiError))
            return
        }

        if response.statusCode == HttpStatusCode.unauthorized.rawValue
            && currentUnauthorizedRetryCount < maxUnauthorizedRetryCount
            && IDKit.isSessionAvailable {
            IDKit.refreshToken { [weak self] result in
                guard case .failure(let error) = result else {
                    let updatedRequest = self?.updateAccessToken(of: request) ?? request
                    _ = self?.makeNetworkRequest(request: updatedRequest,
                                                 currentUnauthorizedRetryCount: currentUnauthorizedRetryCount + 1,
                                                 currentRetryCount: currentRetryCount,
                                                 completion: completion)
                    return
                }

                let returnedResponse: HTTPURLResponse
                if case .internalError = error,
                   let url = response.url,
                   let customResponse: HTTPURLResponse = .init(url: url,
                                                               statusCode: HttpStatusCode.internalError.rawValue,
                                                               httpVersion: nil,
                                                               headerFields: response.allHeaderFields as? [String: String]) {
                    returnedResponse = customResponse
                } else {
                    returnedResponse = response
                }

                self?.handleResponseData(request: request,
                                         data: data,
                                         response: returnedResponse,
                                         completion: completion)
            }
            return
        }

        handleResponseData(request: request,
                           data: data,
                           response: response,
                           completion: completion)
    }

    private func handleResponseData(request: URLRequest,
                                    data: Data?,
                                    response: HTTPURLResponse,
                                    completion: @escaping (Result<Data, APIClientError>) -> Void) {
        let urlString = request.url?.absoluteString ?? "invalid url"

        guard let data = data else {
            SDKLogger.e("[CustomAPIClient] Failed request \(urlString) due to invalid data")
            let error = APIClientError.invalidDataError
            completion(.failure(error))
            return
        }

        let statusCode = response.statusCode

        guard statusCode < HttpStatusCode.badRequest.rawValue else {
            SDKLogger.e("[CustomAPIClient] Failed request \(urlString) with status code \(statusCode)")
            let error = APIClientError.unexpectedStatusCode(statusCode: statusCode, data: data)
            completion(.failure(error))
            return
        }

        completion(.success(data))
    }

    private func modify(request: URLRequest) -> URLRequest {
        var newRequest = request

        if let newRequestUrl = newRequest.url {
            newRequest.url = PACECloudSDK.QueryParamUTMHandler.buildUrl(for: newRequestUrl)
        }

        newRequest.setValue(Constants.Tracing.identifier, forHTTPHeaderField: Constants.Tracing.key)

        for (key, value) in defaultHeaders {
            newRequest.setValue(value, forHTTPHeaderField: key)
        }

        return newRequest
    }

    private func decodeCustomJSONResult<T: Decodable>(_ result: Result<Data, APIClientError>,
                                                      request: URLRequest,
                                                      decoder: JSONDecoder) -> Result<T, APIClientError> {
        switch result {
        case .success(let data):
            do {
                let result = try decoder.decode(T.self, from: data)
                return .success(result)
            } catch {
                SDKLogger.e("[CustomAPIClient] Failed request \(request.url?.absoluteString ?? "invalid url") with error \(error)")
                return .failure(.unknownError(error))
            }

        case .failure(let error):
            return .failure(error)
        }
    }

    private func updateAccessToken(of request: URLRequest) -> URLRequest {
        guard let accessToken = API.accessToken else { return request }

        var updatedRequest = request
        updatedRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: HttpHeaderFields.authorization.rawValue)
        return updatedRequest
    }
}

@MainActor
public extension CustomAPIClient {
    func makeCustomJSONRequest<T: Decodable>(_ request: URLRequest,
                                             session: URLSession = .shared,
                                             decoder: JSONDecoder = JSONDecoder(),
                                             currentUnauthorizedRetryCount: Int = 0,
                                             currentRetryCount: Int = 0) async -> Result<T, APIClientError> {
        await withCheckedContinuation { [weak self] continuation in
            _ = self?.makeCustomJSONRequest(request,
                                            session: session,
                                            decoder: decoder,
                                            currentUnauthorizedRetryCount: currentUnauthorizedRetryCount,
                                            currentRetryCount: currentRetryCount) { response in
                continuation.resume(returning: response)
            }
        }
    }

    func makeCustomDataRequest(_ request: URLRequest,
                               session: URLSession = .shared,
                               currentUnauthorizedRetryCount: Int = 0,
                               currentRetryCount: Int = 0) async -> Result<Data, APIClientError> {
        await withCheckedContinuation { [weak self] continuation in
            _ = self?.makeCustomDataRequest(request,
                                            session: session,
                                            currentUnauthorizedRetryCount: currentUnauthorizedRetryCount,
                                            currentRetryCount: currentRetryCount) { response in
                continuation.resume(returning: response)
            }
        }
    }
}
