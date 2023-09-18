//
//  IDKit+User.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

extension IDKit {
    func userInfo(completion: @escaping (Result<UserInfo, IDKitError>) -> Void) {
        guard let userEndpointUrlString = configuration.userEndpoint,
              let userEndpointUrl = URL(string: userEndpointUrlString) else {
            completion(.failure(.invalidAuthorizationEndpoint))
            return
        }

        performHTTPRequest(for: userEndpointUrl, type: UserInfo.self) { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }

    func paymentMethods(completion: @escaping (Result<PCPayPaymentMethods, IDKitError>) -> Void) {
        let request = PayAPI.PaymentMethods.GetPaymentMethodsIncludingCreditCheck.Request(filterstatus: .valid)
        API.Pay.client.makeRequest(request) { response in
            switch response.result {
            case .success(let result):
                guard result.successful, let paymentMethods = result.success?.data else {
                    if result.statusCode == HttpStatusCode.unauthorized.rawValue {
                        completion(.failure(.invalidSession))
                    } else {
                        completion(.failure(.internalError))
                    }
                    return
                }
                completion(.success(paymentMethods))

            case .failure(let error):
                completion(.failure(.other(error)))
            }
        }
    }

    func transactions(completion: @escaping (Result<PCPayTransactions, IDKitError>) -> Void) {
        let options = PayAPI.PaymentTransactions.ListTransactions.Request.Options(sort: .createdAtDescending)
        let request = PayAPI.PaymentTransactions.ListTransactions.Request(options: options)

        API.Pay.client.makeRequest(request) { response in
            switch response.result {
            case .success(let result):
                guard result.successful, let transactions = result.success?.data else {
                    if result.statusCode == HttpStatusCode.unauthorized.rawValue {
                        completion(.failure(.invalidSession))
                    } else {
                        completion(.failure(.internalError))
                    }
                    return
                }
                completion(.success(transactions))

            case .failure(let error):
                completion(.failure(.other(error)))
            }
        }
    }
}

// MARK: - Concurrency

@MainActor
extension IDKit {
    func userInfo() async -> Result<UserInfo, IDKitError> {
        await checkedContinuation(userInfo)
    }

    func paymentMethods() async -> Result<PCPayPaymentMethods, IDKitError> {
        await checkedContinuation(paymentMethods)
    }

    func transactions() async -> Result<PCPayTransactions, IDKitError> {
       await checkedContinuation(transactions)
    }
}
