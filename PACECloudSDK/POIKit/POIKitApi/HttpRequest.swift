//
//  HttpRequest.swift
//  PACEMapKit
//
//  Created by PACE Telematics GmbH.
//

import Foundation

enum RequestType: String {
    case get = "GET"
    case put = "PUT"
    case post = "POST"
    case patch = "PATCH"
    case delete = "DELETE"
}

class POIKitHTTPReturnCode {
    static let REQUEST_FAILURE = -1
    static let STATUS_OK = 200
    static let STATUS_CREATED = 201
    static let NO_CONTENT = 204
    static let MOVED_PERMANENTLY = 301
    static let BAD_REQUEST = 400
    static let AUTH_FAILED = 401
    static let NOT_FOUND = 404
    static let NOT_ACCEPTABLE = 406
    static let GONE = 410
    static let UNPROCESSABLE = 422
    static let LOCKED = 423
    static let TOO_MANY_REQUESTS = 429
}

protocol HttpRequestProtocol {
    func set(language: String)

    @discardableResult
    func httpRequest(_ method: RequestType, // swiftlint:disable:this function_parameter_count
                     url: URL,
                     body: Data?,
                     includeDefaultHeaders: Bool,
                     headers: [String: String],
                     on queue: DispatchQueue,
                     onCompletion: @escaping (_ response: HTTPURLResponse?, _ data: Data?, _ error: Error?) -> Void) -> URLSessionTask
    func httpRequest(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionTask
}

class HttpRequest: NSObject, HttpRequestProtocol {
    private var session: URLSession = .init(configuration: .default)
    private let sslVerifyHost = "."
    private var acceptLanguage = "en"

    // MARK: - Initialize
    init(session: URLSession? = nil) {
        super.init()

        if let session {
            session.configuration.setCustomURLProtocolIfAvailable()
            session.configuration.httpAdditionalHeaders = [HttpHeaderFields.userAgent.rawValue: Constants.userAgent]
            self.session = session
        } else {
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForRequest = POIKitConfig.connectTimeout
            configuration.timeoutIntervalForResource = POIKitConfig.readTimeout
            configuration.setCustomURLProtocolIfAvailable()
            configuration.httpAdditionalHeaders = [HttpHeaderFields.userAgent.rawValue: Constants.userAgent]
            self.session = URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue())
        }
    }

    func set(language: String) {
        if language == "en" {
            self.acceptLanguage = language
        } else {
            self.acceptLanguage = "\(language), en"
        }
    }

    // MARK: - Requests
    func httpRequest(_ method: RequestType,
                     url: URL,
                     body: Data? = nil,
                     includeDefaultHeaders: Bool = true,
                     headers: [String: String] = [:],
                     on queue: DispatchQueue,
                     onCompletion: @escaping (_ response: HTTPURLResponse?, _ data: Data?, _ error: Error?) -> Void) -> URLSessionTask {
        var request = URLRequest(url: url)

        request.httpMethod = method.rawValue
        headers.forEach { request.addValue($0.value, forHTTPHeaderField: $0.key) }
        if includeDefaultHeaders {
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue(self.acceptLanguage, forHTTPHeaderField: "Accept-Language")
        }

        request.setValue(PACECloudSDK.shared.apiKey ?? "Missing API key", forHTTPHeaderField: HttpHeaderFields.apiKey.rawValue)

        if method != .get, let body = body {
            request.httpBody = body
        }

        return performRequest(request, on: queue, onCompletion: onCompletion)
    }

    func httpRequest(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionTask {
        let task = session.dataTask(with: url, completionHandler: completionHandler)
        task.resume()
        return task
    }

    // MARK: - Multipart Request
    func multipartHttpRequest(url: URL,
                              params: [String: String] = [:],
                              files: [String: String],
                              boundaryID: Int = Int(Date().timeIntervalSince1970),
                              on queue: DispatchQueue,
                              onCompletion: @escaping (_ response: HTTPURLResponse?, _ data: Data?, _ error: Error?) -> Void) {
        var request = URLRequest(url: url)

        let boundary = generateBoundaryString(with: boundaryID)
        let body = createBodyWithParameters(params, files: files, boundary: boundary)

        request.httpMethod = "MULTIPART_FILE_POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(self.acceptLanguage, forHTTPHeaderField: "Accept-Language")

        request.httpBody = body

        _ = performRequest(request, on: queue, onCompletion: onCompletion)
    }

    func generateBoundaryString(with id: Int) -> String {
        return "---Boundary" + "\(id)"
    }

    func createBodyWithParameters(_ parameters: [String: String]?, files: [String: String]?, boundary: String) -> Data {
        let body = NSMutableData()

        if let parameters = parameters {
            for (key, value) in parameters {
                body.appendString("--\(boundary)\r\n")
                body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString("\(value)\r\n")
            }
        }

        if let files = files {
            for (key, file) in files {
                let url = URL(fileURLWithPath: file)
                if let data = try? Data(contentsOf: url) {
                    let filename = url.lastPathComponent
                    let mimetype = MimeTypes(path: filename).value

                    body.appendString("--\(boundary)\r\n")
                    body.appendString("Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(filename)\"\r\n")
                    body.appendString("Content-Type: \(mimetype)\r\n\r\n")
                    body.append(data)
                    body.appendString("\r\n")
                }
            }
        }

        body.appendString("--\(boundary)--\r\n")
        return body as Data
    }

    // MARK: - Generic Request
    private func performRequest(_ request: URLRequest,
                                on queue: DispatchQueue,
                                onCompletion: @escaping (_ response: HTTPURLResponse?, _ data: Data?, _ error: Error?) -> Void) -> URLSessionTask {
        var newRequest = request

        if let oldUrl = request.url, let modifiedUrl = PACECloudSDK.QueryParamUTMHandler.buildUrl(for: oldUrl) {
            newRequest.url = modifiedUrl
        }

        newRequest.setValue(Constants.Tracing.identifier, forHTTPHeaderField: Constants.Tracing.key)

        // Perform task
        let task = self.session.dataTask(with: newRequest, completionHandler: { data, response, error -> Void in
            // Handle response
            queue.async {
                if let requestResponse = response as? HTTPURLResponse {
                    onCompletion(requestResponse, data, error)
                } else {
                    onCompletion(nil, nil, error)
                }
            }
        })

        queue.async {
            task.resume()
        }

        return task
    }
}

extension HttpRequest: URLSessionTaskDelegate {
    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    willPerformHTTPRedirection response: HTTPURLResponse,
                    newRequest request: URLRequest,
                    completionHandler: @escaping (URLRequest?) -> Void) {
        if task.currentRequest?.url?.absoluteString.contains("poi/beta/gas-stations") ?? false {
            // The "gas-stations" endpoint can respond with a `301`
            // that we want to catch since it needs special handling
            completionHandler(nil)
        } else {
            completionHandler(request)
        }
    }
}
