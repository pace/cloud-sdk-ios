//
//  PaymentSelectionViewController.swift
//  PACECloudSDKFueling
//
//  Created by PACE Telematics GmbH.
//

import PACECloudSDK
import UIKit

class PaymentSelectionViewController: UIViewController {
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.register(PaymentMethodCell.self, forCellReuseIdentifier: PaymentMethodCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        return tableView
    }()

    private lazy var loadingSpinner: ActivityIndicatorView = .init()
    private let viewModel: PaymentSelectionViewModel

    private var paymentMethods: [[PCFuelingPaymentMethod]] = []

    init(viewModel: PaymentSelectionViewModel) {
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
        title = "Payment method"
        view.backgroundColor = .white
    }

    private func setupElements() {
        [tableView, loadingSpinner].forEach(view.addSubview)
    }

    private func setupLayout() {
        let constraints = [
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            loadingSpinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingSpinner.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loadingSpinner.heightAnchor.constraint(equalToConstant: 50),
            loadingSpinner.heightAnchor.constraint(equalToConstant: 50)
        ]

        NSLayoutConstraint.activate(constraints)
    }

    private func setupObservers() {
        viewModel.paymentMethods.observe(receiver: self) { [weak self] paymentMethods in
            guard let paymentMethods = paymentMethods else { return }
            self?.paymentMethods = paymentMethods
            self?.tableView.reloadData()
        }
    }

    private func presentErrorAlert(message: String) {
        let alert = UIAlertController.errorAlert(message: message) { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }

        present(alert, animated: true)
    }
}

extension PaymentSelectionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let paymentMethod = paymentMethods[indexPath.section][indexPath.row]
        viewModel.selectPaymentMethod(paymentMethod: paymentMethod)

        let pumpSelectionViewModel = PumpSelectionViewModelImplementation(fuelingProcess: viewModel.fuelingProcess)
        let pumpSelectionViewController = PumpSelectionViewController(viewModel: pumpSelectionViewModel)
        navigationController?.pushViewController(pumpSelectionViewController, animated: true)
    }
}

extension PaymentSelectionViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "Supported payment methods" : "Unsupported payment methods"
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        paymentMethods.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        paymentMethods[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PaymentMethodCell.identifier,
                                                       for: indexPath) as? PaymentMethodCell else { fatalError() }

        let method = paymentMethods[indexPath.section][indexPath.row]

        if let kind = method.localizedKind,
           let identificationString = method.alias ?? method.identificationString {
            let data: PaymentMethodCellData = .init(kind: kind, identificationString: identificationString, isSupported: indexPath.section == 0)
            cell.config(with: data)
        }

        return cell
    }
}
