//
//  LoadingView.swift
//  PACECloudSDKExample
//
//  Created by Patrick Niepel on 06.11.20.
//

import UIKit

class LoadingView: UIView {
    private lazy var label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UIColor.primary
        label.font = UIFont.brandFont
        label.numberOfLines = 0
        label.text = "Finding you the closest CoFu stations..."
        return label
    }()

    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        backgroundColor = .white
        layer.cornerRadius = 10
        layer.borderWidth = 2
        layer.borderColor = UIColor.brand.cgColor

        addSubview(label)
        label.snp.makeConstraints {
            $0.left.right.bottom.equalToSuperview().inset(8)
            $0.top.equalTo(snp.centerY).offset(8)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let size = bounds.height / 3
        let offset = size / 2
        addSubview(SpinningWheel(frame: .init(x: bounds.width / 2 - offset, y: bounds.height / 2 - offset * 2, width: size, height: size)))
    }
}
