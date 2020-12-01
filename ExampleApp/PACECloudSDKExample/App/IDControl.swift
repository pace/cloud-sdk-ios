//
//  IDControl.swift
//  PACECloudSDKExample
//
//  Created by Patrick Niepel on 06.11.20.
//

import PACECloudSDK
import UIKit

protocol IDControlDelegate: AnyObject {
    func isAuthorized(_ authorized: Bool)
    func didReceiveUserInfo(_ userInfo: IDKit.UserInfo)
}

class IDControl {
    static var shared = IDControl()
    weak var delegate: IDControlDelegate?

    private var didSetupAppKit = false

    private init() {}

    func setup(for navigationController: UINavigationController) {
        let config = IDKit.OIDConfiguration(authorizationEndpoint: "https://id.dev.pace.cloud/auth/realms/pace/protocol/openid-connect/auth",
                                            tokenEndpoint: "https://id.dev.pace.cloud/auth/realms/pace/protocol/openid-connect/token",
                                            userEndpoint: "https://id.dev.pace.cloud/auth/realms/pace/protocol/openid-connect/userinfo",
                                            clientId: "cloud-sdk-example-app",
                                            redirectUrl: "pace://cloud-sdk-example")

        IDKit.setup(with: config, cacheSession: true, presentingViewController: navigationController)
    }

    func authorize() {
        IDKit.authorize { [weak self] accessToken, error in
            if let error = error {
                NSLog("Failed authorizing with error \(error)")
                self?.delegate?.isAuthorized(false)
            }

            guard let token = accessToken, !token.isEmpty else {
                NSLog("Token invalid")
                self?.delegate?.isAuthorized(false)
                return
            }

            self?.setupAppKit(with: token)
            self?.delegate?.isAuthorized(true)
            self?.userInfo()
        }
    }

    func refresh(_ completion: @escaping ((String) -> Void)) {
        IDKit.refreshToken { accessToken, error in
            if let error = error {
                NSLog("Failed refreshing with error \(error)")
                self.delegate?.isAuthorized(false)
            }

            guard let token = accessToken, !token.isEmpty else {
                NSLog("Token invalid")
                self.delegate?.isAuthorized(false)
                return
            }

            completion(token)
        }
    }

    func reset() {
        IDKit.resetSession { [weak self] in
            self?.didSetupAppKit = false
            self?.delegate?.isAuthorized(false)
        }
    }

    func userInfo() {
        IDKit.userInfo { [weak self] userInfo, error in
            if let error = error {
                NSLog("UserInfo error \(error)")
            }

            guard let userInfo = userInfo else { return }

            self?.delegate?.didReceiveUserInfo(userInfo)
        }
    }

    private func setupAppKit(with token: String) {
        guard !didSetupAppKit else { return }

        AppControl.shared.setup(with: token)

        didSetupAppKit = true
    }
}
