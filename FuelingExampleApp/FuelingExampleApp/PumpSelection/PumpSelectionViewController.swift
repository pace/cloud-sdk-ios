//
//  PumpSelectionViewController.swift
//  PACECloudSDKFueling
//
//  Created by PACE Telematics GmbH.
//

import PACECloudSDK
import UIKit

class PumpSelectionViewController: UIViewController {
    private let viewModel: PumpSelectionViewModel

    private lazy var collectionView: UICollectionView = {
        var collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(PumpCell.self, forCellWithReuseIdentifier: PumpCell.identifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        return collectionView
    }()

    private lazy var loadingSpinner: ActivityIndicatorView = .init()

    private var pumps: [PCFuelingPump] = []

    init(viewModel: PumpSelectionViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    private func setup() {
        setupSelf()
        setupElements()
        setupLayout()
        setupObservers()
    }

    private func setupSelf() {
        title = "Pump"
        view.backgroundColor = .white
    }

    private func setupElements() {
        [collectionView, loadingSpinner].forEach(view.addSubview)

        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: 100, height: 100)

        collectionView.frame = view.frame
        collectionView.collectionViewLayout = layout
    }

    private func setupLayout() {
        let constraints = [
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            loadingSpinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingSpinner.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loadingSpinner.heightAnchor.constraint(equalToConstant: 50),
            loadingSpinner.heightAnchor.constraint(equalToConstant: 50)
        ]

        NSLayoutConstraint.activate(constraints)
    }

    private func setupObservers() {
        viewModel.pumps.observe(receiver: self) { [weak self] pumps in
            guard let pumps = pumps else { return }
            self?.pumps = pumps
            self?.collectionView.reloadData()
        }

        viewModel.isLoading.observe(receiver: self) { [weak self] isLoading in
            self?.loadingSpinner.isLoading = isLoading ?? false
        }

        viewModel.errorMessage.observe(receiver: self) { [weak self] errorMessage in
            guard let errorMessage = errorMessage else { return }
            self?.presentErrorAlert(message: errorMessage)
        }

        viewModel.showPumpStatus.observe(receiver: self) { [weak self] showPumpStatus in
            guard let self = self, let showPumpStatus = showPumpStatus, showPumpStatus else { return }
            let pumpStatusViewModel = PumpStatusViewModelImplementation(fuelingProcess: self.viewModel.fuelingProcess,
                                                                        postPayPumpInformation: self.viewModel.postPayPumpInformation,
                                                                        postPayPumpStatus: self.viewModel.postPayPumpStatus)
            let pumpStatusViewController = PumpStatusViewController(viewModel: pumpStatusViewModel)
            self.navigationController?.pushViewController(pumpStatusViewController, animated: true)
        }

        viewModel.showAmountSelection.observe(receiver: self) { [weak self] showAmountSelection in
            guard let self = self, let showAmountSelection = showAmountSelection, showAmountSelection else { return }
            let amountSelectionViewModel = AmountSelectionViewModelImplementation(fuelingProcess: self.viewModel.fuelingProcess)
            let amountSelectionViewController = AmountSelectionViewController(viewModel: amountSelectionViewModel)
            self.navigationController?.pushViewController(amountSelectionViewController, animated: true)
        }

        viewModel.showPaymentSummary.observe(receiver: self) { [weak self] showPaymentSummary in
            guard let self = self, let showPaymentSummary = showPaymentSummary, showPaymentSummary else { return }
            let paymentSummaryViewModel = SummaryViewModelImplementation(fuelingProcess: self.viewModel.fuelingProcess)
            let paymentSummaryViewController = SummaryViewController(viewModel: paymentSummaryViewModel)
            self.navigationController?.pushViewController(paymentSummaryViewController, animated: true)
        }
    }

    private func presentErrorAlert(message: String) {
        let alert = UIAlertController.errorAlert(message: message)
        present(alert, animated: true)
    }
}

extension PumpSelectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let pump = pumps[indexPath.item]
        viewModel.selectPump(pump: pump)
    }
}

extension PumpSelectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        pumps.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PumpCell.identifier,
                                                            for: indexPath) as? PumpCell else { fatalError() }

        let pump = pumps[indexPath.item]

        if let identifier = pump.identifier {
            cell.config(with: identifier)
        }

        return cell
    }
}
