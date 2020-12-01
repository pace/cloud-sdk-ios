//
//  NoNetworkPlaceholderView.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import UIKit

class NoNetworkPlaceholderView: UIView {

    private lazy var placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var placeholderTitleLabel: UILabel = {
        let label = UILabel()
        label.font = AppStyle.regularFont(ofSize: 20)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = AppStyle.textColor1
        return label
    }()

    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.font = AppStyle.regularFont(ofSize: 16)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = AppStyle.textColor2
        return label
    }()

    private lazy var retryButton: ButtonRectangular = {
        let button = ButtonRectangular()
        button.tintColor = AppStyle.blueColor
        button.setTitleColor(AppStyle.whiteColor, for: .normal)
        return button
    }()

    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setTitle("action.close".localized, for: .normal)
        button.setTitleColor(AppStyle.blueColor, for: .normal)
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

    init() {
        super.init(frame: CGRect.zero)
        set()
        setup()
    }

    init(titleText: String = "connection.problem.network_headline".localized,
         placeholderText: String = "connection.problem.network".localized,
         buttonText: String = "user.alert.retry".localized,
         image: UIImage = AppStyle.noNetworkIcon,
         hideCloseButton: Bool = false) {
        super.init(frame: .zero)

        set(titleText: titleText, placeholderText: placeholderText, buttonText: buttonText, image: image)
        closeButton.isHidden = hideCloseButton

        setup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        set()
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func set(titleText: String = "connection.problem.network_headline".localized,
             placeholderText: String = "connection.problem.network".localized,
             buttonText: String = "user.alert.retry".localized,
             image: UIImage = AppStyle.noNetworkIcon) {

        placeholderTitleLabel.text = titleText
        placeholderLabel.text = placeholderText
        retryButton.setTitle(buttonText, for: .normal)
        placeholderImageView.image = image
    }

    private func setup() {
        [closeButton, placeholderImageView, placeholderTitleLabel, placeholderLabel, retryButton].forEach { addSubview($0) }

        setupConstraints()
    }

    private func setupConstraints() {
        let padding = AppStyle.leftAndRightScreenPadding

        closeButton.anchor(top: topAnchor, trailing: trailingAnchor, padding: .init(top: padding / 2, left: 0, bottom: 0, right: padding), size: .init(width: 0, height: 35))

        placeholderTitleLabel.anchor(leading: self.leadingAnchor,
                                     trailing: self.trailingAnchor,
                                     centerX: centerXAnchor,
                                     padding: .init(top: 0, left: padding, bottom: 0, right: padding))

        placeholderLabel.anchor(top: placeholderTitleLabel.bottomAnchor,
                                leading: leadingAnchor,
                                trailing: trailingAnchor,
                                centerX: centerXAnchor,
                                centerY: centerYAnchor,
                                padding: .init(top: padding, left: padding, bottom: 0, right: padding))

        placeholderImageView.anchor(bottom: placeholderTitleLabel.topAnchor,
                                    centerX: centerXAnchor,
                                    padding: .init(top: 0, left: 0, bottom: AppStyle.leftAndRightScreenPadding, right: 0),
                                    size: .init(width: self.bounds.width * 0.3, height: 0))

        let paddingButton = AppStyle.buttonScreenPadding
        retryButton.anchor(leading: leadingAnchor,
                      bottom: bottomAnchor,
                      trailing: trailingAnchor,
                      padding: .init(top: 0, left: paddingButton, bottom: 50, right: paddingButton))
    }

    @objc
    private func handleCloseTapped() {
        closeAction?()
    }
}
