//
//  IDKit+HTTPRequest.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

extension IDKit {
    func performHTTPRequest<T: Decodable>(for url: URL, type: T.Type, currentNumberOfRetries: Int = 0, completion: @escaping (Result<T, IDKitError>) -> Void) {
        guard let accessToken = IDKit.latestAccessToken() ?? API.accessToken else {
            completion(.failure(.invalidSession))
            return
        }

        var request = URLRequest(url: url, withTracingId: true)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: HttpHeaderFields.authorization.rawValue)

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            if let error = error {
                completion(.failure(.other(error)))
                return
            }

            guard let response = response as? HTTPURLResponse else {
                completion(.failure(.invalidHTTPURLResponse(url)))
                return
            }

            let statusCode = response.statusCode

            if statusCode >= 400 {
                if statusCode == HttpStatusCode.unauthorized.rawValue
                    && currentNumberOfRetries < 1
                    && IDKit.isSessionAvailable {
                    IDKit.apiInducedRefresh { [weak self] error in
                        guard let error = error else {
                            self?.performHTTPRequest(for: url, type: type, currentNumberOfRetries: currentNumberOfRetries + 1, completion: completion)
                            return
                        }

                        if case .internalError = error {
                            completion(.failure(error))
                        } else {
                            completion(.failure(.statusCode(response.statusCode)))
                        }
                    }
                } else {
                    completion(.failure(.statusCode(response.statusCode)))
                }
            } else {
                self.handleResponseData(for: url,
                                        data: data,
                                        type: type,
                                        completion: completion)
            }
        }.resume()
    }

    func handleResponseData<T: Decodable>(for url: URL, data: Data?, type: T.Type, completion: @escaping (Result<T, IDKitError>) -> Void) {
        guard let data = data else {
            completion(.failure(.invalidData(url)))
            return
        }

        do {
            let result = try JSONDecoder().decode(type, from: data)
            completion(.success(result))
        } catch {
            completion(.failure(.other(error)))
        }
    }
}
