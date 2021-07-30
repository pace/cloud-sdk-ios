//
//  UIAlertController+Extension.swift
//  PACECloudSDKExample
//
//  Created by PACE Telematics GmbH.
//

import Foundation
import SwiftUI

extension UIAlertController {
    convenience init(alert: TextFieldAlert) {
        self.init(title: alert.title, message: alert.message, preferredStyle: .alert)

        alert.textFields.forEach { alertTextfield in
            addTextField {
                $0.placeholder = alertTextfield.placeholder
                $0.keyboardType = alertTextfield.keyboardType
            }
        }

        if let cancel = alert.cancel {
            addAction(UIAlertAction(title: cancel, style: .cancel) { _ in
                alert.action([])
            })
        }

        addAction(UIAlertAction(title: alert.accept, style: .default) { [weak self] _ in
            let texts: [String?] = self?.textFields?.map {
                if ($0.text ?? "").isEmpty {
                    return nil
                } else {
                    return $0.text
                }
            } ?? []
            alert.action(texts)
        })

        if let secondaryActionTitle = alert.secondaryActionTitle {
            addAction(UIAlertAction(title: secondaryActionTitle, style: .default, handler: { _ in
                alert.secondaryAction?()
            }))
        }
    }
}
