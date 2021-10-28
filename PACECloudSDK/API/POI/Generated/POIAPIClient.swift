//
// Generated by SwagGen
// https://github.com/pace/SwagGen
//

import Foundation

/// Manages and sends APIRequests
public class POIAPIClient {

    public static var `default` = POIAPIClient(baseURL: "https://api.pace.cloud/poi")

    /// A list of RequestBehaviours that can be used to monitor and alter all requests
    public var behaviours: [POIAPIRequestBehaviour] = [POIAPIRequestBehaviourImplementation()]

    /// The base url prepended before every request path
    public var baseURL: String

    /// The UrlSession used for each request
    public var session: URLSession

    /// These headers will get added to every request
    public var defaultHeaders: [String: String]

    public var jsonDecoder = JSONDecoder()
    public var jsonEncoder = JSONEncoder()

    public var decodingQueue = DispatchQueue(label: "POIAPIClient", qos: .utility, attributes: .concurrent)

    public var maxUnauthorizedRetryCount = 1

    public init(baseURL: String, configuration: URLSessionConfiguration = .default, defaultHeaders: [String: String] = [:], behaviours: [POIAPIRequestBehaviour] = []) {
        self.baseURL = baseURL
        self.behaviours = self.behaviours + behaviours
        self.defaultHeaders = defaultHeaders
        jsonDecoder.dateDecodingStrategy = .custom(dateDecoder)
        jsonEncoder.dateEncodingStrategy = .formatted(POIAPI.dateEncodingFormatter)
        self.session = URLSession(configuration: configuration, delegate: nil, delegateQueue: OperationQueue())
    }

    /// Makes a network request
    ///
    /// - Parameters:
    ///   - request: The API request to make
    ///   - behaviours: A list of behaviours that will be run for this request. Merged with APIClient.behaviours
    ///   - completionQueue: The queue that complete will be called on
    ///   - complete: A closure that gets passed the POIAPIResponse
    /// - Returns: A cancellable request. Not that cancellation will only work after any validation RequestBehaviours have run
    @discardableResult
    public func makeRequest<T>(_ request: POIAPIRequest<T>, behaviours: [POIAPIRequestBehaviour] = [], currentNumberOfRetries: Int = 0, completionQueue: DispatchQueue = DispatchQueue.main, complete: @escaping (POIAPIResponse<T>) -> Void) -> CancellablePOIAPIRequest? {
        // create composite behaviour to make it easy to call functions on array of behaviours
        let requestBehaviour = POIAPIRequestBehaviourGroup(request: request, behaviours: self.behaviours + behaviours)

        // create the url request from the request
        var urlRequest: URLRequest
        do {
            urlRequest = try request.createURLRequest(baseURL: baseURL, encoder: jsonEncoder)
        } catch {
            let error = APIClientError.requestEncodingError(error)
            requestBehaviour.onFailure(response: HTTPURLResponse(), error: error)
            let response = POIAPIResponse<T>(request: request, result: .failure(error))
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

        urlRequest = requestBehaviour.modifyRequest(urlRequest)

        let cancellableRequest = CancellablePOIAPIRequest(request: request.asAny())

        requestBehaviour.validate(urlRequest) { result in
            switch result {
            case .success(let urlRequest):
                self.makeNetworkRequest(request: request, urlRequest: urlRequest, cancellableRequest: cancellableRequest, requestBehaviour: requestBehaviour, currentNumberOfRetries: currentNumberOfRetries, completionQueue: completionQueue, complete: complete)
            case .failure(let error):
                let error = APIClientError.validationError(error)
                let response = POIAPIResponse<T>(request: request, result: .failure(error), urlRequest: urlRequest)
                requestBehaviour.onFailure(response: HTTPURLResponse(), error: error)
                complete(response)
            }
        }
        return cancellableRequest
    }

    private func makeNetworkRequest<T>(request: POIAPIRequest<T>, urlRequest: URLRequest, cancellableRequest: CancellablePOIAPIRequest, requestBehaviour: POIAPIRequestBehaviourGroup, currentNumberOfRetries: Int, completionQueue: DispatchQueue, complete: @escaping (POIAPIResponse<T>) -> Void) {
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
            let task = self.session.dataTask(with: urlRequest, completionHandler: { [weak self] data, response, error -> Void in
                // Handle response
                self?.decodingQueue.async {
                    guard let response = response as? HTTPURLResponse else {
                        var apiError: APIClientError
                        if let error = error {
                            apiError = APIClientError.networkError(error)
                        } else {
                            apiError = APIClientError.networkError(URLRequestError.responseInvalid)
                        }
                        let result: APIResult<T> = .failure(apiError)
                        requestBehaviour.onFailure(response: HTTPURLResponse(), error: apiError)

                        let response = POIAPIResponse<T>(request: request, result: result, urlRequest: urlRequest)
                        requestBehaviour.onResponse(response: response.asAny())

                        completionQueue.async {
                            complete(response)
                        }

                        return
                    }

                    self?.handleResponse(request: request,
                                         requestBehaviour: requestBehaviour,
                                         data: data,
                                         response: response,
                                         error: error,
                                         urlRequest: urlRequest,
                                         currentNumberOfRetries: currentNumberOfRetries,
                                         completionQueue: completionQueue,
                                         complete: complete)
                }
            })

            self.decodingQueue.async {
                task.resume()
            }

            cancellableRequest.sessionTask = task
        }
    }

    private func handleResponse<T>(request: POIAPIRequest<T>,
                                   requestBehaviour: POIAPIRequestBehaviourGroup,
                                   data: Data?,
                                   response: HTTPURLResponse,
                                   error: Error?,
                                   urlRequest: URLRequest,
                                   currentNumberOfRetries: Int,
                                   completionQueue: DispatchQueue,
                                   complete: @escaping (POIAPIResponse<T>) -> Void) {
        let result: APIResult<T>

        if let error = error {
            let apiError = APIClientError.networkError(error)
            result = .failure(apiError)
            requestBehaviour.onFailure(response: response, error: apiError)
            let response = POIAPIResponse<T>(request: request, result: result, urlRequest: urlRequest, urlResponse: response, data: data)
            requestBehaviour.onResponse(response: response.asAny())

            completionQueue.async {
                complete(response)
            }
            return
        }

        if response.statusCode == HttpStatusCode.unauthorized.rawValue
            && currentNumberOfRetries < maxUnauthorizedRetryCount
            && IDKit.isSessionAvailable {
            IDKit.apiInducedRefresh { [weak self] isSuccessful in
                guard isSuccessful else {
                    self?.handleResponseData(request: request,
                                             requestBehaviour: requestBehaviour,
                                             data: data,
                                             response: response,
                                             urlRequest: urlRequest,
                                             completionQueue: completionQueue,
                                             complete: complete)
                    return
                }
                self?.makeRequest(request, behaviours: requestBehaviour.behaviours, currentNumberOfRetries: currentNumberOfRetries + 1, completionQueue: completionQueue, complete: complete)
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

    private func handleResponseData<T>(request: POIAPIRequest<T>,
                                       requestBehaviour: POIAPIRequestBehaviourGroup,
                                       data: Data?,
                                       response: HTTPURLResponse,
                                       urlRequest: URLRequest,
                                       completionQueue: DispatchQueue,
                                       complete: @escaping (POIAPIResponse<T>) -> Void) {
        let result: APIResult<T>

        guard let data = data else {
            let error = APIClientError.invalidDataError
            result = .failure(error)
            requestBehaviour.onFailure(response: response, error: error)
            let response = POIAPIResponse<T>(request: request, result: result, urlRequest: urlRequest, urlResponse: response, data: nil)
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
                requestBehaviour.onFailure(response: response, error: .unexpectedStatusCode(statusCode: statusCode, data: data))
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
            requestBehaviour.onFailure(response: response, error: apiError)
        }

        let response = POIAPIResponse<T>(request: request, result: result, urlRequest: urlRequest, urlResponse: response, data: data)
        requestBehaviour.onResponse(response: response.asAny())

        completionQueue.async {
            complete(response)
        }
    }
}
