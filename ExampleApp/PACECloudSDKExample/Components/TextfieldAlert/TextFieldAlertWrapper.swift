//
//  TextFieldAlertWrapper.swift
//  PACECloudSDKExample
//
//  Created by PACE Telematics GmbH.
//

import Foundation
import SwiftUI

struct TextFieldAlertWrapper<Content: View>: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    let alert: TextFieldAlert
    let content: Content

    func makeUIViewController(context: UIViewControllerRepresentableContext<TextFieldAlertWrapper>) -> UIHostingController<Content> {
        UIHostingController(rootView: content)
    }

    class Coordinator {
        var alertController: UIAlertController?
        init(_ controller: UIAlertController? = nil) {
            self.alertController = controller
        }
    }

    func makeCoordinator() -> Coordinator {
        .init()
    }

    func updateUIViewController(_ uiViewController: UIHostingController<Content>, context: UIViewControllerRepresentableContext<TextFieldAlertWrapper>) {
        uiViewController.rootView = content
        if isPresented
            && uiViewController.presentedViewController == nil {
            var alert = self.alert
            alert.action = {
                self.isPresented = false
                self.alert.action($0)
            }
            let alertController = UIAlertController(alert: alert)
            context.coordinator.alertController = alertController
            uiViewController.present(alertController, animated: true)
        } else if !isPresented
                    && uiViewController.presentedViewController == context.coordinator.alertController {
            uiViewController.dismiss(animated: true)
        }
    }
}
