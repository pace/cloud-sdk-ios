//
//  AppActivityIndicatorView.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import UIKit

class AppActivityIndicatorView: UIActivityIndicatorView {

    override init(style: UIActivityIndicatorView.Style = .medium) {
        super.init(style: style)

        color = AppStyle.blueColor
        hidesWhenStopped = true
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
}
