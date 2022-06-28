//
//  PumpStatusViewController.swift
//  PACECloudSDKFueling
//
//  Created by PACE Telematics GmbH.
//

import UIKit

class PumpStatusViewController: UIViewController {
    private lazy var statusTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Loading pump data..."
        label.font = label.font.withSize(32)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()

    private lazy var statusDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = label.font.withSize(24)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textColor = .gray
        return label
    }()

    private lazy var cancelTransactionButton: UIButton = {
        let button = UIButton()
        button.setTitle("Cancel", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 24)
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 8
        button.backgroundColor = .paceBlue
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
        return button
    }()

    private lazy var loadingSpinner: ActivityIndicatorView = .init()

    private let viewModel: PumpStatusViewModel

    init(viewModel: PumpStatusViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        viewModel.initiatePumpStatusHandling()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.reset()
    }

    private func setup() {
        setupSelf()
        setupElements()
        setupLayout()
        setupObservers()
    }

    private func setupSelf() {
        title = "Pump status"
        view.backgroundColor = .white

        if viewModel.fuelingProcess.isPreAuth {
            navigationItem.setHidesBackButton(true, animated: false)
        }
    }

    private func setupElements() {
        [statusTitleLabel, statusDescriptionLabel, loadingSpinner].forEach(view.addSubview)
    }

    private func setupLayout() {
        let constraints = [
            statusTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusTitleLabel.bottomAnchor.constraint(equalTo: view.centerYAnchor),
            statusTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            statusDescriptionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusDescriptionLabel.topAnchor.constraint(equalTo: view.centerYAnchor, constant: 8),
            statusDescriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusDescriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            loadingSpinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingSpinner.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loadingSpinner.heightAnchor.constraint(equalToConstant: 50),
            loadingSpinner.heightAnchor.constraint(equalToConstant: 50)
        ]

        NSLayoutConstraint.activate(constraints)
    }

    private func setupObservers() {
        viewModel.status.observe(receiver: self) { [weak self] status in
            guard let status = status else { return }
            self?.statusTitleLabel.text = status.titleText
            self?.statusDescriptionLabel.text = status.descriptionText
        }

        viewModel.isLoading.observe(receiver: self) { [weak self] isLoading in
            self?.loadingSpinner.isLoading = isLoading ?? false
        }

        viewModel.errorMessage.observe(receiver: self) { [weak self] errorMessage in
            guard let errorMessage = errorMessage else { return }
            self?.presentErrorAlert(message: errorMessage)
        }

        viewModel.didFinishPostPay.observe(receiver: self) { [weak self] pumpInformation in
            guard let self = self,
                  let navigationController = self.navigationController,
                  let pumpInformation = pumpInformation else { return }

            let fuelingProcess = self.viewModel.fuelingProcess
            fuelingProcess.pumpInformation = pumpInformation

            let paymentSummaryViewModel = SummaryViewModelImplementation(fuelingProcess: fuelingProcess)
            let paymentSummaryViewController = SummaryViewController(viewModel: paymentSummaryViewModel)

            var currentViewControllers: [UIViewController] = navigationController.viewControllers.dropLast().map { $0 } // Prevents going back to pump status
            currentViewControllers.append(paymentSummaryViewController)

            navigationController.setViewControllers(currentViewControllers, animated: true)
        }

        viewModel.didFinishPreAuth.observe(receiver: self) { [weak self] paymentSuccessData in
            guard let self = self, let paymentSuccessData = paymentSuccessData else { return }

            let paymentSuccessViewModel = SuccessViewModelImplementation(paymentSuccessData: paymentSuccessData)
            let paymentSuccessViewController = SuccessViewController(viewModel: paymentSuccessViewModel)
            self.navigationController?.setViewControllers([paymentSuccessViewController], animated: true)
        }

        viewModel.showCancelTransactionButton.observe(receiver: self) { [weak self] showCancelTransactionButton in
            guard let showCancelTransactionButton = showCancelTransactionButton else { return }
            self?.toggleCancelButtonAppearance(showCancelButton: showCancelTransactionButton)
        }

        viewModel.showCancelTransactionSuccess.observe(receiver: self) { [weak self] showCancelTransactionSuccess in
            guard let showCancelTransactionSuccess = showCancelTransactionSuccess, showCancelTransactionSuccess else { return }
            let successAlert = UIAlertController.alert(title: "Successfully canceled the transaction", message: nil) { [weak self] in
                self?.popBackToPumpSelection()
            }
            self?.present(successAlert, animated: true)
        }

        viewModel.popBackToPumpSelection.observe(receiver: self) { [weak self] popBackToPumpSelection in
            guard let popBackToPumpSelection = popBackToPumpSelection, popBackToPumpSelection else { return }
            self?.popBackToPumpSelection()
        }
    }

    private func toggleCancelButtonAppearance(showCancelButton: Bool) {
        if showCancelButton, cancelTransactionButton.superview == nil {
            view.addSubview(cancelTransactionButton)
            cancelTransactionButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            cancelTransactionButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -80).isActive = true
            cancelTransactionButton.widthAnchor.constraint(equalToConstant: 180).isActive = true
            cancelTransactionButton.heightAnchor.constraint(equalToConstant: 60).isActive = true

        } else {
            cancelTransactionButton.removeFromSuperview()
        }
    }

    @objc
    private func didTapCancel() {
        let confirmationAlert = UIAlertController.actionsAlert(title: "Are you sure?",
                                                               message: nil,
                                                               actions: [
                                                                .init(title: "Yes", style: .default, handler: { [weak self] _ in
                                                                    self?.viewModel.cancelTransaction()
                                                                }),
                                                                .init(title: "No", style: .cancel, handler: nil)
                                                               ])
        present(confirmationAlert, animated: true)
    }

    private func popBackToPumpSelection() {
        guard let pumpSelectionViewController = navigationController?.viewControllers.first(where: { $0 is PumpSelectionViewController }) else { return }
        navigationController?.popToViewController(pumpSelectionViewController, animated: true)
    }

    private func presentErrorAlert(message: String) {
        let alert = UIAlertController.errorAlert(message: message) { [weak self] in
            self?.popBackToPumpSelection()
        }

        present(alert, animated: true)
    }
}
