//
//  SummaryItemsView.swift
//  FuelingExampleApp
//
//  Created by PACE Telematics GmbH.
//

import UIKit

class SummaryItemsView: UIView {
    private lazy var collectionView: UICollectionView = {
        var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(SummaryItemCell.self, forCellWithReuseIdentifier: SummaryItemCell.identifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isUserInteractionEnabled = false
        return collectionView
    }()

    private var summaryItems: [SummaryItem] = []

    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(collectionView)

        let constraints = [
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ]

        NSLayoutConstraint.activate(constraints)
    }

    func updateSummaryItems(_ items: [SummaryItem]) {
        self.summaryItems = items
        collectionView.reloadData()
    }
}

extension SummaryItemsView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else { return .zero }
        let width = (collectionView.bounds.width - flowLayout.minimumInteritemSpacing - 40) / 2
        return .init(width: width, height: 75)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 20)
    }
}

extension SummaryItemsView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        summaryItems.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SummaryItemCell.identifier,
                                                            for: indexPath) as? SummaryItemCell else { fatalError() }

        let summaryItem = summaryItems[indexPath.item]
        cell.config(with: summaryItem)

        return cell
    }
}
