//
//  IDKit+App+TokenHandling.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import AppAuth
import Foundation

extension IDKit {
    func performAppInducedRefresh(force: Bool = false, _ completion: @escaping (String?) -> Void) {
        guard IDKit.isSessionAvailable else {
            performAppInducedAuthorization(completion)
            return
        }

        performRefresh(force: force) { [weak self] result in
            switch result {
            case .success(let accessToken):
                completion(accessToken)

            case .failure(let error):
                guard case .failedTokenRefresh = error else {
                    completion(nil)
                    return
                }

                self?.performAppInducedSessionReset(with: error, completion)
            }
        }
    }

    func performAppInducedAuthorization(_ completion: @escaping (String?) -> Void) {
        performAuthorization(showSignInMask: true) { [weak self] result in
            switch result {
            case .success(let accessToken):
                if let accessToken = accessToken {
                    self?.delegate?.didPerformAuthorization(.success(accessToken))
                }
                completion(accessToken)

            case .failure(let error):
                self?.delegate?.didPerformAuthorization(.failure(error))
                IDKitLogger.e("App induced authorization failed with error \(error).")
                completion(nil)
            }
        }
    }

    func performAppInducedSessionReset(with error: IDKitError?, _ completion: @escaping (String?) -> Void) {
        performReset { [weak self] result in
            switch result {
            case .success:
                self?.delegate?.didFailSessionRenewal(with: error, completion) ?? self?.performAppInducedAuthorization(completion)

            case .failure(let error):
                Logger.w(error.description)
                completion("")
            }
        }
    }
}
