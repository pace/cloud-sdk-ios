//
//  UIViewController+Extension.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import UIKit

extension UIViewController {
    var isGettingDismissed: Bool {
        isBeingDismissed ||
        isMovingFromParent ||
        navigationController?.isBeingDismissed == true ||
        isUnderlyingViewControllerBeingDismissed(of: self)
    }

    private func isUnderlyingViewControllerBeingDismissed(of viewController: UIViewController?) -> Bool {
        let presentingViewController = viewController?.presentingViewController
        let presentedViewController = viewController?.presentedViewController

        if presentingViewController == nil && presentedViewController == nil {
            return false
        }

        if presentingViewController == nil {
            if presentedViewController?.isBeingDismissed == true {
                return true
            }

            return isUnderlyingViewControllerBeingDismissed(of: presentedViewController)
        }

        if presentedViewController == nil {
            if presentingViewController?.isBeingDismissed == true {
                return true
            }

            return isUnderlyingViewControllerBeingDismissed(of: presentingViewController)
        }

        return isUnderlyingViewControllerBeingDismissed(of: presentingViewController) || isUnderlyingViewControllerBeingDismissed(of: presentedViewController)
    }
}
