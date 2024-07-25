//
// Generated by SwagGen
// https://github.com/pace/SwagGen
//

import Foundation
import Japx

/// Manages and sends APIRequests
public class UserAPIClient {

    public static var `default` = UserAPIClient(baseURL: "https://api.pace.cloud/user")

    /// A list of RequestBehaviours that can be used to monitor and alter all requests
    public var behaviours: [UserAPIRequestBehaviour] = [UserAPIRequestBehaviourImplementation()]

    /// The base url prepended before every request path
    public var baseURL: String

    /// The UrlSession used for each request
    public var session: URLSession

    /// These headers will get added to every request
    public var defaultHeaders: [String: String]

    public var jsonDecoder = JapxDecoder()
    public var jsonEncoder = JSONEncoder()

    public var decodingQueue = DispatchQueue(label: "UserAPIClient", qos: .utility, attributes: .concurrent)

    /// The maximum number a request will be retried due to `401` responses
    public var maxUnauthorizedRetryCount = 1

    /// The maximum number a request will be retried due to network connection errors and timeouts
    public var maxRetryCount = 8

    public init(baseURL: String, configuration: URLSessionConfiguration = .default, defaultHeaders: [String: String] = [:], behaviours: [UserAPIRequestBehaviour] = []) {
        self.baseURL = baseURL
        self.behaviours = self.behaviours + behaviours
        self.defaultHeaders = defaultHeaders
        jsonDecoder.jsonDecoder.dateDecodingStrategy = .custom(dateDecoder)
        jsonEncoder.dateEncodingStrategy = .formatted(UserAPI.dateEncodingFormatter)
        self.session = URLSession(configuration: configuration, delegate: nil, delegateQueue: OperationQueue())
    }

    /// Makes a network request
    ///
    /// - Parameters:
    ///   - request: The API request to make
    ///   - behaviours: A list of behaviours that will be run for this request. Merged with APIClient.behaviours
    ///   - currentUnauthorizedRetryCount: The current number of retries for this request due to `401` responses
    ///   - currentRetryCount: The current number of retries for this request due to network connection errors and timeouts
    ///   - completionQueue: The queue that complete will be called on
    ///   - complete: A closure that gets passed the UserAPIResponse
    /// - Returns: A cancellable request. Note that cancellation will only work after any validation RequestBehaviours have run
    @discardableResult
    public func makeRequest<T>(_ request: UserAPIRequest<T>,
                               behaviours: [UserAPIRequestBehaviour] = [],
                               currentUnauthorizedRetryCount: Int = 0,
                               currentRetryCount: Int = 0,
                               completionQueue: DispatchQueue = DispatchQueue.main,
                               complete: @escaping (UserAPIResponse<T>) -> Void) -> CancellableUserAPIRequest? {
        // create composite behaviour to make it easy to call functions on array of behaviours
        let requestBehaviour = UserAPIRequestBehaviourGroup(request: request, behaviours: self.behaviours + behaviours)

        // create the url request from the request
        var urlRequest: URLRequest
        do {
            urlRequest = try request.createURLRequest(baseURL: baseURL, encoder: jsonEncoder)
        } catch {
            let error = APIClientError.requestEncodingError(error)
            requestBehaviour.onFailure(urlRequest: nil, response: HTTPURLResponse(), error: error)
            let response = UserAPIResponse<T>(request: request, result: .failure(error))
            complete(response)
            return nil
        }

        // add the default headers
        if urlRequest.allHTTPHeaderFields == nil {
            urlRequest.allHTTPHeaderFields = [:]
        }
        for (key, value) in defaultHeaders {
            urlRequest.allHTTPHeaderFields?[key] = value
        }

        let cancellableRequest = CancellableUserAPIRequest(request: request.asAny())

        urlRequest = requestBehaviour.modifyRequest(urlRequest)

        if request.isAuthorizationRequired
            && request.customHeaders[HttpHeaderFields.authorization.rawValue] == nil
            && IDKit.isSessionAvailable {
            IDKit.refreshToken { [weak self] result in
                guard let self else { return }
                guard case let .failure(error) = result else {
                    guard case let .success(accessToken) = result, 
                            let accessToken else { return }
                    urlRequest.setValue("Bearer \(accessToken)", 
                                        forHTTPHeaderField: HttpHeaderFields.authorization.rawValue)
                    self.validateNetworkRequest(request: request,
                                                urlRequest: urlRequest,
                                                cancellableRequest: cancellableRequest,
                                                requestBehaviour: requestBehaviour,
                                                currentUnauthorizedRetryCount: currentUnauthorizedRetryCount,
                                                currentRetryCount: currentRetryCount,
                                                completionQueue: completionQueue,
                                                complete: complete)
                    return
                }

                if case .failedTokenRefresh = error {
                    completionQueue.async {
                        let response = UserAPIResponse<T>(request: request,
                                                                     result: .failure(APIClientError
                                                                        .unexpectedStatusCode(statusCode: 401,
                                                                                              data: Data("UNAUTHORIZED".utf8))))
                        complete(response)
                    }
                } else {
                    completionQueue.async {
                        let response = UserAPIResponse<T>(request: request,
                                                                     result: .failure(APIClientError.unknownError(error)))
                        complete(response)
                    }
                }
            }
        } else {
            validateNetworkRequest(request: request,
                                   urlRequest: urlRequest,
                                   cancellableRequest: cancellableRequest,
                                   requestBehaviour: requestBehaviour,
                                   currentUnauthorizedRetryCount: currentUnauthorizedRetryCount,
                                   currentRetryCount: currentRetryCount,
                                   completionQueue: completionQueue,
                                   complete: complete)
        }

        return cancellableRequest
    }

    private func validateNetworkRequest<T>(request: UserAPIRequest<T>,
                                           urlRequest: URLRequest,
                                           cancellableRequest: CancellableUserAPIRequest,
                                           requestBehaviour: UserAPIRequestBehaviourGroup,
                                           currentUnauthorizedRetryCount: Int,
                                           currentRetryCount: Int,
                                           completionQueue: DispatchQueue,
                                           complete: @escaping (UserAPIResponse<T>) -> Void) {
        requestBehaviour.validate(urlRequest) { result in
            switch result {
            case .success(let urlRequest):
                self.makeNetworkRequest(request: request,
                                        urlRequest: urlRequest,
                                        cancellableRequest: cancellableRequest,
                                        requestBehaviour: requestBehaviour,
                                        currentUnauthorizedRetryCount: currentUnauthorizedRetryCount,
                                        currentRetryCount: currentRetryCount,
                                        completionQueue: completionQueue, complete: complete)
            case .failure(let error):
                let error = APIClientError.validationError(error)
                let response = UserAPIResponse<T>(request: request, result: .failure(error), urlRequest: urlRequest)
                requestBehaviour.onFailure(urlRequest: urlRequest, response: HTTPURLResponse(), error: error)
                complete(response)
            }
        }
    }

    private func makeNetworkRequest<T>(request: UserAPIRequest<T>,
                                       urlRequest: URLRequest,
                                       cancellableRequest: CancellableUserAPIRequest,
                                       requestBehaviour: UserAPIRequestBehaviourGroup,
                                       currentUnauthorizedRetryCount: Int,
                                       currentRetryCount: Int,
                                       completionQueue: DispatchQueue,
                                       complete: @escaping (UserAPIResponse<T>) -> Void) {
        requestBehaviour.beforeSend()
        if request.service.isUpload {
            let body = NSMutableData()
            let boundary = "---Boundary" + "\(Int(Date().timeIntervalSince1970))"

            for (key, value) in request.formParameters {
                body.appendString("--\(boundary)\r\n")
                if let file = value as? UploadFile {
                    switch file.type {
                    case let .url(url):
                        if let fileName = file.fileName, let mimeType = file.mimeType {
                            body.appendString("--\(boundary)\r\n")
                            body.appendString("Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(fileName)\"\r\n")
                            body.appendString("Content-Type: \(mimeType)\r\n\r\n")
                            body.appendString(url.absoluteString)
                            body.appendString("\r\n")
                        } else {
                            body.appendString("--\(boundary)\r\n")
                            body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                            body.appendString("\(url.absoluteString)\r\n")
                        }
                    case let .data(data):
                        if let fileName = file.fileName, let mimeType = file.mimeType {
                            body.appendString("--\(boundary)\r\n")
                            body.appendString("Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(fileName)\"\r\n")
                            body.appendString("Content-Type: \(mimeType)\r\n\r\n")
                            body.append(data)
                            body.appendString("\r\n")
                        } else {
                            body.appendString("--\(boundary)\r\n")
                            body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                            body.append(data)
                            body.appendString("\r\n")
                        }
                    }
                } else if let url = value as? URL {
                    body.appendString("--\(boundary)\r\n")
                    body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                    body.appendString("\(url.absoluteString)\r\n")
                } else if let data = value as? Data {
                    body.appendString("--\(boundary)\r\n")
                    body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                    body.append(data)
                    body.appendString("\r\n")
                } else if let string = value as? String {
                    body.appendString("--\(boundary)\r\n")
                    body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                    body.append(Data(string.utf8))
                    body.appendString("\r\n")
                }
            }
            body.appendString("--\(boundary)--\r\n")
        } else {
            let task = performRequest(request: request,
                                      urlRequest: urlRequest,
                                      cancellableRequest: cancellableRequest,
                                      requestBehaviour: requestBehaviour,
                                      currentUnauthorizedRetryCount: currentUnauthorizedRetryCount,
                                      currentRetryCount: currentRetryCount,
                                      completionQueue: completionQueue,
                                      complete: complete)

            self.decodingQueue.async {
                task.resume()
            }

            cancellableRequest.sessionTask = task
        }
    }

    private func performRequest<T>(request: UserAPIRequest<T>,
                                   urlRequest: URLRequest,
                                   cancellableRequest: CancellableUserAPIRequest,
                                   requestBehaviour: UserAPIRequestBehaviourGroup,
                                   currentUnauthorizedRetryCount: Int,
                                   currentRetryCount: Int,
                                   completionQueue: DispatchQueue,
                                   complete: @escaping (UserAPIResponse<T>) -> Void) -> URLSessionDataTask {
        let maxRetryCount = maxRetryCount
        return session.dataTask(with: urlRequest, completionHandler: { [weak self] data, response, error -> Void in
            // Handle response
            self?.decodingQueue.async {
                let newRetryCount = currentRetryCount + 1
                if API.shouldRetryRequest(currentRetryCount: newRetryCount,
                                          maxRetryCount: maxRetryCount,
                                          response: response) {
                    let requestDelay = API.nextExponentialBackoffRequestDelay(currentRetryCount: newRetryCount)
                    self?.decodingQueue.asyncAfter(deadline: .now() + .seconds(requestDelay)) { [weak self] in
                        self?.makeNetworkRequest(request: request,
                                                 urlRequest: urlRequest,
                                                 cancellableRequest: cancellableRequest,
                                                 requestBehaviour: requestBehaviour,
                                                 currentUnauthorizedRetryCount: currentUnauthorizedRetryCount,
                                                 currentRetryCount: newRetryCount,
                                                 completionQueue: completionQueue,
                                                 complete: complete)
                    }
                } else if let response = response as? HTTPURLResponse {
                    self?.handleResponse(request: request,
                                         requestBehaviour: requestBehaviour,
                                         data: data,
                                         response: response,
                                         error: error,
                                         urlRequest: urlRequest,
                                         currentUnauthorizedRetryCount: currentUnauthorizedRetryCount,
                                         currentRetryCount: currentRetryCount,
                                         completionQueue: completionQueue,
                                         complete: complete)
                } else {
                    var apiError: APIClientError
                    if let error = error {
                        apiError = APIClientError.networkError(error)
                    } else {
                        apiError = APIClientError.networkError(URLRequestError.responseInvalid)
                    }
                    let result: APIResult<T> = .failure(apiError)
                    requestBehaviour.onFailure(urlRequest: urlRequest, response: HTTPURLResponse(), error: apiError)

                    let response = UserAPIResponse<T>(request: request, result: result, urlRequest: urlRequest)
                    requestBehaviour.onResponse(response: response.asAny())

                    completionQueue.async {
                        complete(response)
                    }
                }
            }
        })
    }

    private func handleResponse<T>(request: UserAPIRequest<T>,
                                   requestBehaviour: UserAPIRequestBehaviourGroup,
                                   data: Data?,
                                   response: HTTPURLResponse,
                                   error: Error?,
                                   urlRequest: URLRequest,
                                   currentUnauthorizedRetryCount: Int,
                                   currentRetryCount: Int,
                                   completionQueue: DispatchQueue,
                                   complete: @escaping (UserAPIResponse<T>) -> Void) {
        let result: APIResult<T>

        if let error = error {
            let apiError = APIClientError.networkError(error)
            result = .failure(apiError)
            requestBehaviour.onFailure(urlRequest: urlRequest, response: response, error: apiError)
            let response = UserAPIResponse<T>(request: request, result: result, urlRequest: urlRequest, urlResponse: response, data: data)
            requestBehaviour.onResponse(response: response.asAny())

            completionQueue.async {
                complete(response)
            }
            return
        }

        if response.statusCode == HttpStatusCode.unauthorized.rawValue
            && request.customHeaders[HttpHeaderFields.authorization.rawValue] == nil
            && currentUnauthorizedRetryCount < maxUnauthorizedRetryCount
            && IDKit.isSessionAvailable {
            IDKit.refreshToken(force: true) { [weak self] result in
                guard case .failure(let error) = result else {
                    self?.makeRequest(request,
                                      behaviours: requestBehaviour.behaviours,
                                      currentUnauthorizedRetryCount: currentUnauthorizedRetryCount + 1,
                                      currentRetryCount: currentRetryCount,
                                      completionQueue: completionQueue,
                                      complete: complete)
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
                                         requestBehaviour: requestBehaviour,
                                         data: data,
                                         response: returnedResponse,
                                         urlRequest: urlRequest,
                                         completionQueue: completionQueue,
                                         complete: complete)
            }
            return
        }

        handleResponseData(request: request,
                           requestBehaviour: requestBehaviour,
                           data: data,
                           response: response,
                           urlRequest: urlRequest,
                           completionQueue: completionQueue,
                           complete: complete)
    }

    private func handleResponseData<T>(request: UserAPIRequest<T>,
                                       requestBehaviour: UserAPIRequestBehaviourGroup,
                                       data: Data?,
                                       response: HTTPURLResponse,
                                       urlRequest: URLRequest,
                                       completionQueue: DispatchQueue,
                                       complete: @escaping (UserAPIResponse<T>) -> Void) {
        let result: APIResult<T>

        guard let data = data else {
            let error = APIClientError.invalidDataError
            result = .failure(error)
            requestBehaviour.onFailure(urlRequest: urlRequest, response: response, error: error)
            let response = UserAPIResponse<T>(request: request, result: result, urlRequest: urlRequest, urlResponse: response, data: nil)
            requestBehaviour.onResponse(response: response.asAny())

            completionQueue.async {
                complete(response)
            }
            return
        }

        do {
            let statusCode = response.statusCode
            let decoded = try T(statusCode: statusCode, data: data, decoder: jsonDecoder)
            result = .success(decoded)
            if decoded.successful {
                requestBehaviour.onSuccess(result: decoded.response as Any)
            } else {
                requestBehaviour.onFailure(urlRequest: urlRequest, response: response, error: .unexpectedStatusCode(statusCode: statusCode, data: data))
            }
        } catch let error {
            let apiError: APIClientError
            if let error = error as? DecodingError {
                apiError = APIClientError.decodingError(error)
            } else if let error = error as? APIClientError {
                apiError = error
            } else {
                apiError = APIClientError.unknownError(error)
            }

            result = .failure(apiError)
            requestBehaviour.onFailure(urlRequest: urlRequest, response: response, error: apiError)
        }

        let response = UserAPIResponse<T>(request: request, result: result, urlRequest: urlRequest, urlResponse: response, data: data)
        requestBehaviour.onResponse(response: response.asAny())

        completionQueue.async {
            complete(response)
        }
    }
}

@MainActor
public extension UserAPIClient {
    /// Makes a network request
    ///
    /// - Parameters:
    ///   - request: The API request to make
    ///   - behaviours: A list of behaviours that will be run for this request. Merged with APIClient.behaviours
    ///   - currentUnauthorizedRetryCount: The current number of retries for this request due to `401` responses
    ///   - currentRetryCount: The current number of retries for this request due to network connection errors and timeouts
    /// - Returns: An asynchronously-delivered result that either contains the response of the request
    func makeRequest<T>(_ request: UserAPIRequest<T>,
                        behaviours: [UserAPIRequestBehaviour] = [],
                        currentUnauthorizedRetryCount: Int = 0,
                        currentRetryCount: Int = 0) async -> UserAPIResponse<T> {
        await withCheckedContinuation { [weak self] continuation in
            _ = self?.makeRequest(request, behaviours: behaviours,
                                  currentUnauthorizedRetryCount: currentUnauthorizedRetryCount,
                                  currentRetryCount: currentRetryCount,
                                  complete: { response in
                continuation.resume(returning: response)
            })
        }
    }
}
