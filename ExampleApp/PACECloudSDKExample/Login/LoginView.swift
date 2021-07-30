//
//  LoginView.swift
//  PACECloudSDKExample
//
//  Created by PACE Telematics GmbH.
//

import PACECloudSDK
import SwiftUI

struct LoginView: View {
    private let viewModel: LoginViewModel

    init(viewModel: LoginViewModel = LoginViewModelImplementation()) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            Spacer()
            Text("PACECloudSDK Example App")
                .foregroundColor(.black)
                .font(.system(size: 32).weight(.semibold))
                .multilineTextAlignment(.center)
                .padding([.leading, .trailing], .defaultPadding)
            Spacer()
            RectangularButton(title: "Login / Register", action: startLoginProcess)
            .padding([.leading, .trailing], .defaultPadding)
            Spacer()
        }
    }
}

private extension LoginView {
    func startLoginProcess() {
        let viewController = UIHostingController(rootView: self)
        viewModel.authorize(presentingViewController: viewController)
    }
}
