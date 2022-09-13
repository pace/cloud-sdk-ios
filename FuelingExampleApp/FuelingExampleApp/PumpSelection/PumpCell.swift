//
//  PumpCell.swift
//  FuelingExampleApp
//
//  Created by PACE Telematics GmbH.
//

import UIKit

class PumpCell: UICollectionViewCell {
    static let identifier: String = "PumpCell"

    private lazy var numberLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = label.font.withSize(32)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var cellBackground: UIView = {
        let view = UIView()
        view.backgroundColor = .paceBlue
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        setupElements()
        setupLayout()
    }

    private func setupElements() {
        [cellBackground, numberLabel].forEach { contentView.addSubview($0) }
    }

    private func setupLayout() {
        let constraints = [
            cellBackground.topAnchor.constraint(equalTo: contentView.topAnchor),
            cellBackground.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            cellBackground.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            cellBackground.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            numberLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            numberLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            numberLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            numberLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ]

        NSLayoutConstraint.activate(constraints)
    }

    func config(with identifier: String) {
        numberLabel.text = identifier
    }
}
