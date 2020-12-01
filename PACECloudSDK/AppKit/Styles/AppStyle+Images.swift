//
//  AppStyle+Images.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import UIKit

extension AppStyle {
    static var noNetworkIcon: UIImage {
        return imageNamed("no_internet_connection")
    }

    static var pacePayLogoSmall: UIImage {
        return imageNamed("pace_pay_small")
    }

    static var iconNotificationError: UIImage {
        return imageNamed("notification_error")
    }

    static var roundCloseIcon: UIImage {
        return imageNamed("round_close_icon")
    }

    static var webBackIcon: UIImage {
        return imageNamed("webBackIcon")
    }

    static var webForwardIcon: UIImage {
        return imageNamed("webForwardIcon")
    }

    static var lockIcon: UIImage {
        return imageNamed("lock").withRenderingMode(.alwaysTemplate)
    }

    private static func imageNamed(_ imageName: String) -> UIImage {
        return UIImage(named: imageName, in: Bundle.paceCloudSDK, compatibleWith: nil) ?? UIImage()
    }
}
