//
//  IDKit+App+TokenHandling.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import AppAuth
import Foundation

extension IDKit {
    func performAppInducedRefresh(_ completion: @escaping (String?) -> Void) {
        guard IDKit.isSessionAvailable else {
            performAppInducedAuthorization(completion)
            return
        }

        performRefresh { [weak self] accessToken, error in
            guard let error = error else {
                completion(accessToken)
                return
            }

            guard case .failedTokenRefresh = error else {
                completion(nil)
                return
            }

            self?.performAppInducedSessionReset(with: error, completion)
        }
    }

    func performAppInducedAuthorization(_ completion: @escaping (String?) -> Void) {
        performAuthorization(showSignInMask: true) { accessToken, error in
            if let error = error {
                self.delegate?.didPerformAuthorization(.failure(error))
                IDKitLogger.e("App induced authorization failed with error \(error).")
            } else if let accessToken = accessToken {
                self.delegate?.didPerformAuthorization(.success(accessToken))
            }
            completion(accessToken)
        }
    }

    func performAppInducedSessionReset(with error: IDKitError?, _ completion: @escaping (String?) -> Void) {
        performReset { [weak self] in
            self?.delegate?.didFailSessionRenewal(with: error, completion) ?? self?.performAppInducedAuthorization(completion)
        }
    }
}
