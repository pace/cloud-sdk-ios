//
//  GasStationListViewController.swift
//  PACECloudSDKFueling
//
//  Created by PACE Telematics GmbH.
//

import PACECloudSDK
import UIKit

class GasStationListViewController: UIViewController {
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.register(GasStationCell.self, forCellReuseIdentifier: "GasStationCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false

        return tableView
    }()

    private lazy var loadingSpinner: ActivityIndicatorView = .init()
    private lazy var refreshControl = UIRefreshControl()

    private let viewModel: GasStationListViewModel

    init(viewModel: GasStationListViewModel) {
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
        title = "Gas Stations"
        view.backgroundColor = .white
    }

    private func setupElements() {
        [tableView, loadingSpinner].forEach(view.addSubview)

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 600

        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
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
        viewModel.gasStations.observe(receiver: self) { [weak self] _ in
            self?.tableView.reloadData()
        }

        viewModel.errorMessage.observe(receiver: self) { [weak self] errorMessage in
            guard let errorMessage = errorMessage else { return }
            self?.presentErrorAlert(message: errorMessage)
        }

        viewModel.isLoading.observe(receiver: self) { [weak self] isLoading in
            self?.loadingSpinner.isLoading = isLoading ?? false
        }

        viewModel.didApproachGasStation.observe(receiver: self) { [weak self] fuelingProcess in
            guard let fuelingProcess = fuelingProcess else { return }
            let paymentSelectionViewModel = PaymentSelectionViewModelImplementation(fuelingProcess: fuelingProcess)
            let paymentSelectionViewController = PaymentSelectionViewController(viewModel: paymentSelectionViewModel)
            self?.navigationController?.pushViewController(paymentSelectionViewController, animated: true)
        }
    }

    private func presentErrorAlert(message: String) {
        let alert = UIAlertController.errorAlert(message: message)
        present(alert, animated: true)
    }

    @objc
    private func refresh(_ sender: AnyObject) {
        viewModel.fetchCofuStations()

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4)) {
            self.refreshControl.endRefreshing()
        }
    }
}

extension GasStationListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let station = viewModel.gasStations.value?[indexPath.row] else {
            return
        }

        viewModel.approachGasStation(gasStation: station)
    }
}

extension GasStationListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.gasStations.value?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "GasStationCell",
                                                       for: indexPath) as? GasStationCell else { fatalError() }

        guard let station = viewModel.gasStations.value?[indexPath.row] else {
            return UITableViewCell()
        }

        cell.config(with: station)

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}
