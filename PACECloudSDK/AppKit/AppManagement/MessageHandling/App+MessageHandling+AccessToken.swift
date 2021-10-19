//
//  App+AccessToken.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

extension App {
    func handleGetAccessToken(with request: API.Communication.GetAccessTokenRequest, completion: @escaping (API.Communication.GetAccessTokenResult) -> Void) {
        guard PACECloudSDK.shared.authenticationMode == .native else { return }

        let requestReason = request.reason

        let reason = AppKit.GetAccessTokenReason(rawValue: requestReason) ?? .other
        let oldToken = request.oldToken

        guard IDKit.isSetUp else {
            AppKit.shared.notifyGetAccessToken(reason: reason, oldToken: oldToken) { response in
                completion(.init(.init(response: response)))
            }
            return
        }

        if reason == .unauthorized,
           let oldToken = oldToken,
           IDKit.TokenValidator.isTokenValid(oldToken) {
            IDKit.appInducedSessionReset { [weak self] accessToken in
                self?.respond(accessToken: accessToken, completion)
            }
            return
        }

        IDKit.appInducedRefresh { [weak self] accessToken in
            self?.respond(accessToken: accessToken, completion)
        }
    }

    private func respond(accessToken: String?, _ completion: @escaping (API.Communication.GetAccessTokenResult) -> Void) {
        if let token = accessToken {
            completion(.init(.init(response: .init(accessToken: token, isInitialToken: nil))))
        } else {
            completion(.init(.init(statusCode: .internalServerError, response: .init(message: "The access token couldn't be retrieved."))))
        }
    }

    func handleIsSignedIn(completion: @escaping (API.Communication.IsSignedInResult) -> Void) {
        guard PACECloudSDK.shared.authenticationMode == .native else { return }
        completion(.init(.init(response: .init(signedIn: IDKit.isAuthorizationValid()))))
    }
}
