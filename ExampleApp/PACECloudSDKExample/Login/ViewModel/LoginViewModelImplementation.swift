//
//  LoginViewModelImplementation.swift
//  PACECloudSDKExample
//
//  Created by PACE Telematics GmbH.
//

import Foundation
import SwiftUI

class LoginViewModelImplementation: LoginViewModel {
    func authorize(presentingViewController: UIViewController) {
        IDControl.shared.authorize(with: presentingViewController)
    }
}
