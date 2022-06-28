//
//  UIAlertController+Extension.swift
//  FuelingExampleApp
//
//  Created by PACE Telematics GmbH.
//

import UIKit

extension UIAlertController {
    static func alert(title: String, message: String?, completion: (() -> Void)? = nil) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        }
        alert.addAction(okAction)
        return alert
    }

    static func errorAlert(message: String?, completion: (() -> Void)? = nil) -> UIAlertController {
        let alert = UIAlertController(title: "An error occured", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        }
        alert.addAction(okAction)
        return alert
    }

    static func retryAlert(title: String, message: String?, retryHandler: @escaping () -> Void, restartHandler: @escaping () -> Void) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let retryAction = UIAlertAction(title: "Retry", style: .default) { _ in
            retryHandler()
        }

        let restartAction = UIAlertAction(title: "Restart", style: .default) { _ in
            restartHandler()
        }

        [retryAction, restartAction].forEach {
            alert.addAction($0)
        }

        return alert
    }

    static func actionsAlert(title: String?, message: String?, actions: [UIAlertAction]) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        actions.forEach { alert.addAction($0) }
        return alert
    }
}
