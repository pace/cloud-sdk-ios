//
//  PaymentMethodCell.swift
//  FuelingExampleApp
//
//  Created by PACE Telematics GmbH.
//

import UIKit

struct PaymentMethodCellData {
    let kind: String
    let identificationString: String
    let isSupported: Bool
}

class PaymentMethodCell: UITableViewCell {
    static let identifier: String = "PaymentMethodCell"

    private lazy var identificationLabel: UILabel = {
        let label = UILabel()
        label.font = label.font.withSize(16)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .gray
        return label
    }()

    private lazy var kindLabel: UILabel = {
        let label = UILabel()
        label.font = label.font.withSize(20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
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
        accessoryType = .disclosureIndicator

        [identificationLabel, kindLabel].forEach(contentView.addSubview)
    }

    private func setupLayout() {
        let constraints = [
            identificationLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            identificationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            identificationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            kindLabel.topAnchor.constraint(equalTo: identificationLabel.bottomAnchor, constant: 0),
            kindLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            kindLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            kindLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ]

        NSLayoutConstraint.activate(constraints)
    }

    func config(with data: PaymentMethodCellData) {
        kindLabel.text = data.kind.capitalized
        identificationLabel.text = data.identificationString
        isUserInteractionEnabled = data.isSupported
    }
}
