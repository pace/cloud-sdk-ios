//
//  GasStationCell.swift
//  PACECloudSDKFueling
//
//  Created by PACE Telematics GmbH.
//

import UIKit

class GasStationCell: UITableViewCell {
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = label.font.withSize(24)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var addressLabel1: UILabel = {
        let label = UILabel()
        label.font = label.font.withSize(16)
        label.numberOfLines = 0
        label.setContentHuggingPriority(.required, for: .vertical)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .gray
        return label
    }()

    private lazy var addressLabel2: UILabel = {
        let label = UILabel()
        label.font = label.font.withSize(16)
        label.numberOfLines = 0
        label.setContentHuggingPriority(.required, for: .vertical)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .gray
        return label
    }()

    private lazy var distanceLabel: UILabel = {
        let label = UILabel()
        label.font = label.font.withSize(16)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .gray
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

        [nameLabel, addressLabel1, addressLabel2, distanceLabel].forEach { contentView.addSubview($0) }
    }

    private func setupLayout() {
        let constraints = [
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            nameLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20),
            nameLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20),

            addressLabel1.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
            addressLabel1.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20),
            addressLabel1.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20),

            addressLabel2.topAnchor.constraint(equalTo: addressLabel1.bottomAnchor, constant: 2),
            addressLabel2.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20),
            addressLabel2.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20),

            distanceLabel.topAnchor.constraint(equalTo: addressLabel2.bottomAnchor, constant: 5),
            distanceLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20),
            distanceLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20),
            distanceLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ]

        NSLayoutConstraint.activate(constraints)
    }

    func config(with station: GasStation) {
        nameLabel.text = station.name
        addressLabel1.text = station.addressLine1
        addressLabel2.text = station.addressLine2
        distanceLabel.text = "Distance: \(station.formattedDistance)"
    }
}
