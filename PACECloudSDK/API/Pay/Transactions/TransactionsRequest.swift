//
//  TransactionsRequest.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

public extension API.Pay {
    static func fetchTransactions(environment: PayEnvironmentBaseUrl, accessToken: String, limit: Int? = nil, completion: @escaping (Result<TransactionsResponse, Error>) -> Void) {
        let urlString = environment.rawValue + "/transactions"
        var component = URLComponents(string: urlString)

        if let limit = limit {
            component?.queryItems?.append(.init(name: "page[size]", value: "\(limit)"))
        }

        component?.queryItems?.append(.init(name: "sort", value: "createdAt"))

        guard let url = component?.url else {
            completion(.failure(HttpUrlError.invalidUrl(urlString)))
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: HttpHeaderFields.authorization.rawValue)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let response = response as? HTTPURLResponse else {
                completion(.failure(HttpUrlError.invalidHTTPURLResponse(url)))
                return
            }

            guard response.statusCode < 400 else {
                completion(.failure(HttpUrlError.statusCode(response.statusCode)))
                return
            }

            guard let data = data else {
                completion(.failure(HttpUrlError.invalidData(url)))
                return
            }

            do {
                let result = try JSONDecoder().decode(TransactionsResponse.self, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
