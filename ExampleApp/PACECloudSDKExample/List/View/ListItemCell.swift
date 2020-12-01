//
//  ListItemCell.swift
//  PACECloudSDKExample
//
//  Created by Patrick Niepel on 05.11.20.
//

import UIKit

class ListItemCell: UITableViewCell {
    private var listItem: ListItem?

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.brandFont
        label.textColor = UIColor.primary
        return label
    }()

    private lazy var distanceLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.font = UIFont.brandFont
        label.textColor = UIColor.primary
        return label
    }()

    private lazy var addressLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.addressFont
        label.textColor = UIColor.secondary
        label.numberOfLines = 2
        return label
    }()

    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        distanceLabel.text = nil
        addressLabel.text = nil
    }

    func setup(with listItem: ListItem) {
        self.listItem = listItem

        accessoryType = .disclosureIndicator

        nameLabel.text = listItem.name

        let street = listItem.street
        let houseNo = listItem.houseNo
        let city = listItem.city
        let postalCode = listItem.postalCode

        addressLabel.text = "\(street) \(houseNo) - \(postalCode), \(city)"

        let distance = listItem.distance
        let unit = distance >= 1000 ? "km" : "m"
        let value: Int

        if distance >= 1000 {
            let roundedValue = 1000.0 * (distance / 1000.0).rounded()
            value = Int(roundedValue / 1000)
        } else {
            value = Int(distance)
        }

        distanceLabel.text = ["~", "\(value)", unit].joined(separator: " ")

        setupLayout()
    }

    private func setupLayout() {
        [nameLabel, distanceLabel, addressLabel].forEach(contentView.addSubview)

        nameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(4)
            $0.bottom.equalTo(contentView.snp.centerY)
            $0.left.equalToSuperview().inset(16)
        }

        distanceLabel.snp.makeConstraints {
            $0.top.bottom.equalTo(nameLabel)
            $0.left.equalTo(nameLabel.snp.right).offset(16)
            $0.right.equalToSuperview()
        }

        addressLabel.snp.makeConstraints {
            $0.top.equalTo(contentView.snp.centerY).offset(-8)
            $0.bottom.equalToSuperview().inset(4)
            $0.left.right.equalToSuperview().inset(16)
        }
    }
}
