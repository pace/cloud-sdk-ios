//
//  PaceButton.swift
//  PACECloudSDKExample
//
//  Created by Patrick Niepel on 05.11.20.
//

import UIKit

class PaceButton: UIButton {
    init(frame: CGRect = .zero, with title: String) {
        super.init(frame: frame)

        setTitle(title, for: .normal)
        setTitleColor(UIColor.background, for: .normal)
        titleLabel?.font = UIFont.buttonFont
        backgroundColor = UIColor.brand
        layer.cornerRadius = 10
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
