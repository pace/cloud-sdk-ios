//
//  CustomURLProtocol.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

class CustomURLProtocol: URLProtocol {
    struct Constants {
        static let RequestHandledKey = "URLProtocolRequestHandled"
    }

    var session: URLSession?
    var sessionTask: URLSessionDataTask?

    override init(request: URLRequest, cachedResponse: CachedURLResponse?, client: URLProtocolClient?) {
        super.init(request: request, cachedResponse: cachedResponse, client: client)

        if session == nil {
            session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        }
    }

    override class func canInit(with request: URLRequest) -> Bool {
        if CustomURLProtocol.property(forKey: Constants.RequestHandledKey, in: request) != nil {
            return false
        }
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        guard let url = request.url else { return request }

        var newRequest = request
        newRequest.url = QueryParamHandler.buildUrl(for: url)

        return newRequest
    }

    override func startLoading() {
        guard let newRequest = (request as NSURLRequest).mutableCopy() as? NSMutableURLRequest else { return }

        CustomURLProtocol.setProperty(true, forKey: Constants.RequestHandledKey, in: newRequest)
        sessionTask = session?.dataTask(with: newRequest as URLRequest)
        sessionTask?.resume()
    }

    override func stopLoading() {
        sessionTask?.cancel()
    }
}

extension CustomURLProtocol: URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        client?.urlProtocol(self, didLoad: data)
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        let policy = URLCache.StoragePolicy(rawValue: request.cachePolicy.rawValue) ?? .notAllowed
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: policy)
        completionHandler(.allow)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            client?.urlProtocol(self, didFailWithError: error)
        } else {
            client?.urlProtocolDidFinishLoading(self)
        }
    }

    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    willPerformHTTPRedirection response: HTTPURLResponse,
                    newRequest request: URLRequest,
                    completionHandler: @escaping (URLRequest?) -> Void) {
        client?.urlProtocol(self, wasRedirectedTo: request, redirectResponse: response)
        completionHandler(request)
    }

    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        guard let error = error else { return }
        client?.urlProtocol(self, didFailWithError: error)
    }

    func urlSession(_ session: URLSession,
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let protectionSpace = challenge.protectionSpace
        let sender = challenge.sender

        if protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            if let serverTrust = protectionSpace.serverTrust {
                let credential = URLCredential(trust: serverTrust)
                sender?.use(credential, for: challenge)
                completionHandler(.useCredential, credential)
                return
            }
        }
    }

    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        client?.urlProtocolDidFinishLoading(self)
    }
}
