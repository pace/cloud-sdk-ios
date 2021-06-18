//
//  App+AccessToken.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

extension App {
    func handleGetAccessTokenRequest(with request: AppKit.AppRequestData<AppKit.GetAccessTokenData>,
                                     completion: @escaping () -> Void) {
        guard PACECloudSDK.shared.authenticationMode == .native else { return }

        let requestReason = request.message.reason

        let reason = AppKit.GetAccessTokenReason(rawValue: requestReason) ?? .other
        let oldToken = request.message.oldToken

        guard IDKit.isSetUp else {
            AppKit.shared.notifyGetAccessToken(reason: reason, oldToken: oldToken) { [weak self] response in
                self?.messageInterceptor?.respond(id: request.id, message: response.toDictionary())
                completion()
            }
            return
        }

        if reason == .unauthorized,
           let oldToken = oldToken,
           AppKit.TokenValidator.isTokenValid(oldToken) {
            IDKit.appInducedSessionReset { [weak self] accessToken in
                self?.respond(with: request.id, accessToken: accessToken, completion)
            }
            return
        }

        IDKit.appInducedRefresh { [weak self] accessToken in
            self?.respond(with: request.id, accessToken: accessToken, completion)
        }
    }

    private func respond(with id: String, accessToken: String?, _ completion: @escaping () -> Void) {
        if let token = accessToken {
            let response: AppKit.GetAccessTokenResponse = .init(accessToken: token)
            messageInterceptor?.respond(id: id, message: response.toDictionary())
        } else {
            messageInterceptor?.send(id: id, error: .internalError)
        }
        completion()
    }
}
