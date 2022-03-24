//
//  LoadingView.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import UIKit

class LoadingView: UIView {
    lazy var loadingIndicator = AppActivityIndicatorView()

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = PACECloudSDK.shared.localizable.loadingText
        label.font = AppStyle.regularFont(ofSize: 17)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    var isLoading: Bool = true {
        didSet {
            isLoading ? loadingIndicator.startAnimating() : loadingIndicator.stopAnimating()
        }
    }

    override init(frame: CGRect = .zero) {
        super.init(frame: frame)

        setupView()
        updatePACEStyle()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupView() {
        addSubview(loadingIndicator)
        loadingIndicator.anchor(top: topAnchor, centerX: centerXAnchor, padding: .init(top: 138, left: 0, bottom: 0, right: 0), size: .init(width: 96, height: 96))

        addSubview(titleLabel)
        titleLabel.anchor(top: loadingIndicator.bottomAnchor,
                          centerX: centerXAnchor,
                          padding: .init(top: 48, left: 0, bottom: 0, right: 0),
                          size: .init(width: self.bounds.width * 0.6, height: 0))
    }

    func updatePACEStyle() {
        backgroundColor = AppStyle.backgroundColor3
        titleLabel.textColor = AppStyle.textColor1
    }
}
