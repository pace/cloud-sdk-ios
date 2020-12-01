//
//  NavigationTitleView.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import UIKit

class NavigationTitleView: UIView {
    lazy var lockIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = AppStyle.textColor1
        return imageView
    }()

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = AppStyle.regularFont(ofSize: 16)
        label.textAlignment = .center
        label.numberOfLines = 1
        label.textColor = AppStyle.textColor1
        return label
    }()

    var shouldShowLockIcon: Bool = false {
        didSet {
            adjustTitleView()
        }
    }

    init() {
        super.init(frame: CGRect.zero)
        setup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func set(titleText: String?, showLockIcon: Bool) {
        titleLabel.text = titleText
        shouldShowLockIcon = showLockIcon
    }

    private func setup() {
        addSubview(titleLabel)
        addSubview(lockIconImageView)

        lockIconImageView.anchor(leading: self.leadingAnchor,
                                 trailing: titleLabel.leadingAnchor,
                                 centerY: centerYAnchor,
                                 padding: .init(top: 0, left: 0, bottom: 0, right: 5),
                                 size: .init(width: 15, height: 15))
        titleLabel.anchor(trailing: self.trailingAnchor, centerY: centerYAnchor)
    }

    private func adjustTitleView() {
        lockIconImageView.image = shouldShowLockIcon ? AppStyle.lockIcon : nil
    }
}
