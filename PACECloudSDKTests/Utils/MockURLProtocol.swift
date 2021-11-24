//
//  MockURLProtocol.swift
//  PACECloudSDKTests
//
//  Created by PACE Telematics GmbH.
//

import Foundation

class MockURLProtocol: URLProtocol {
    private var session: URLSession?
    private var sessionTask: URLSessionDataTask?

    override init(request: URLRequest, cachedResponse: CachedURLResponse?, client: URLProtocolClient?) {
        super.init(request: request, cachedResponse: cachedResponse, client: client)

        if session == nil {
            session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        }
    }

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        guard let urlString = request.url?.absoluteString else { return }

        guard let mockObject = determineMockObject(for: urlString) else {
            NSLog("[MockURLProtocol] No mocked response available for url: \(urlString)")
            sessionTask = session?.dataTask(with: request)
            sessionTask?.resume()
            return
        }

        // Simulate the response on a background thread.
        DispatchQueue.global(qos: .default).async {
            if let requestURL = URL(string: mockObject.url),
               let httpUrlResponse = HTTPURLResponse(url: requestURL, statusCode: mockObject.statusCode, httpVersion: nil, headerFields: nil) {
                self.client?.urlProtocol(self, didReceive: httpUrlResponse, cacheStoragePolicy: .allowed)
            }

            switch mockObject.mockData {
            case .success(let data):
                self.client?.urlProtocol(self, didLoad: data)
                self.client?.urlProtocolDidFinishLoading(self)

            case .failure(let error):
                self.client?.urlProtocol(self, didFailWithError: error)
            }
        }
    }

    override func stopLoading() {
        sessionTask?.cancel()
    }

    private func determineMockObject(for url: String) -> MockObject? {
        switch url {
        case _ where url.hasPrefix("https://api.dev.pace.cloud/geo/2021-1/apps/pace-drive-ios-min.geojson"):
            return MockData.GeoServiceMockObject()

        default:
            return nil
        }
    }
}

extension MockURLProtocol: URLSessionDataDelegate {
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

