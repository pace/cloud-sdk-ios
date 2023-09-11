//
//  UIWindow+Extension.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import UIKit

extension UIWindow {
    static var topMostWindowLevel: UIWindow.Level? {
        #if EXTENSION
        return UIWindow.Level.alert - 1
        #else
        return sortedWindowStack.first?.windowLevel
        #endif
    }

    static var sortedWindowStack: [UIWindow] {
        return (Application.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene)?.windows
            .sorted(by: { $0.windowLevel > $1.windowLevel }) ?? []
    }

    static var topMost: UIWindow? {
        sortedWindowStack.first
    }
}
