//
//  ErrorPlaceholderView.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import UIKit

class ErrorPlaceholderView: UIView {
    private lazy var placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var placeholderTitleLabel: UILabel = {
        let label = UILabel()
        label.font = AppStyle.lightFont(ofSize: 18)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = AppStyle.textColor1
        return label
    }()

    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.font = AppStyle.lightFont(ofSize: 14)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = AppStyle.textColor2
        return label
    }()

    private lazy var retryButton: ButtonRectangular = {
        let button = ButtonRectangular()
        button.tintColor = AppStyle.blueColor
        button.setTitleColor(AppStyle.whiteColor, for: .normal)
        button.titleLabel?.font = AppStyle.regularFont(ofSize: 18)
        return button
    }()

    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setTitle(PACECloudSDK.shared.localizable.commonClose, for: .normal)
        button.setTitleColor(AppStyle.textColor1, for: .normal)
        button.addTarget(self, action: #selector(handleCloseTapped), for: .touchUpInside)
        return button
    }()

    var closeAction: (() -> Void)?

    var action: ((AnyObject) -> Void)? {
        didSet {
            guard let action = action else { return }
            retryButton.addAction(action, forControlEvents: .touchUpInside)
        }
    }

    init(titleText: String = PACECloudSDK.shared.localizable.errorGeneric,
         placeholderText: String = "",
         buttonText: String = PACECloudSDK.shared.localizable.commonRetry,
         image: UIImage = AppStyle.iconNotificationError,
         hideCloseButton: Bool = false) {
        super.init(frame: .zero)

        set(titleText: titleText, placeholderText: placeholderText, buttonText: buttonText, image: image)
        closeButton.isHidden = hideCloseButton

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func set(titleText: String,
             placeholderText: String,
             buttonText: String,
             image: UIImage) {
        placeholderTitleLabel.text = titleText
        placeholderLabel.text = placeholderText
        retryButton.setTitle(buttonText, for: .normal)
        placeholderImageView.image = image
    }

    private func setup() {
        [closeButton, placeholderImageView, placeholderTitleLabel, placeholderLabel, retryButton].forEach { addSubview($0) }

        setupConstraints()
        backgroundColor = AppStyle.backgroundColor3
    }

    private func setupConstraints() {
        let padding: CGFloat = 20

        closeButton.anchor(top: topAnchor, trailing: trailingAnchor, padding: .init(top: padding / 2, left: 0, bottom: 0, right: padding), size: .init(width: 0, height: 40))

        placeholderTitleLabel.anchor(leading: leadingAnchor,
                                     trailing: trailingAnchor,
                                     centerX: centerXAnchor,
                                     padding: .init(top: 0, left: padding, bottom: 0, right: padding))

        placeholderLabel.anchor(top: placeholderTitleLabel.bottomAnchor,
                                leading: leadingAnchor,
                                trailing: trailingAnchor,
                                centerX: centerXAnchor,
                                centerY: centerYAnchor,
                                padding: .init(top: padding / 2, left: padding, bottom: 0, right: padding))

        placeholderImageView.anchor(bottom: placeholderTitleLabel.topAnchor,
                                    centerX: centerXAnchor,
                                    padding: .init(top: 0, left: 0, bottom: AppStyle.leftAndRightScreenPadding, right: 0),
                                    size: .init(width: self.bounds.width * 0.3, height: 0))

        retryButton.anchor(leading: leadingAnchor,
                           bottom: bottomAnchor,
                           trailing: trailingAnchor,
                           padding: .init(top: 0, left: padding, bottom: 50, right: padding),
                           size: .init(width: 0, height: 44))
    }

    @objc
    private func handleCloseTapped() {
        closeAction?()
    }
}
