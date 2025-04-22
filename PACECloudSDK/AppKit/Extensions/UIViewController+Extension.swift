//
//  UIViewController+Extension.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import UIKit

extension UIViewController {
    var isGettingDismissed: Bool {
        return isBeingDismissed
        || isMovingFromParent
        || navigationController?.isBeingDismissed == true
        || checkUnderlyingDismissal()
    }

    private func checkUnderlyingDismissal() -> Bool {
        var visited = Set<ObjectIdentifier>()
        return isUnderlyingViewControllerBeingDismissed(of: self, visited: &visited)
    }

    private func isUnderlyingViewControllerBeingDismissed(
        of viewController: UIViewController?,
        visited: inout Set<ObjectIdentifier>
    ) -> Bool {
        guard let vc = viewController else { return false }
        let id = ObjectIdentifier(vc)
        guard !visited.contains(id) else { return false }
        visited.insert(id)

        if isParentDismissed(vc, visited: &visited) {
            return true
        }

        return isChildDismissed(vc, visited: &visited)
    }

    private func isParentDismissed(
        _ vc: UIViewController,
        visited: inout Set<ObjectIdentifier>
    ) -> Bool {
        guard let presenting = vc.presentingViewController else { return false }

        if presenting.isBeingDismissed {
            return true
        }

        return isUnderlyingViewControllerBeingDismissed(
            of: presenting,
            visited: &visited
        )
    }

    private func isChildDismissed(
        _ vc: UIViewController,
        visited: inout Set<ObjectIdentifier>
    ) -> Bool {
        guard let presented = vc.presentedViewController else { return false }

        if presented.isBeingDismissed {
            return true
        }

        return isUnderlyingViewControllerBeingDismissed(
            of: presented,
            visited: &visited
        )
    }
}
