//
//  SummaryViewController.swift
//  PACECloudSDKFueling
//
//  Created by PACE Telematics GmbH.
//

import PACECloudSDK
import UIKit

class SummaryViewController: UIViewController {
    private let viewModel: SummaryViewModel

    private lazy var summaryItemsView: SummaryItemsView = .init()

    private lazy var payButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .boldSystemFont(ofSize: 24)
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 8
        button.backgroundColor = .paceBlue
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapPayButton), for: .touchUpInside)
        return button
    }()

    private lazy var loadingSpinner: ActivityIndicatorView = .init()

    init(viewModel: SummaryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        viewModel.requestDiscountInformationIfNeeded()
    }

    private func setup() {
        setupSelf()
        setupElements()
        setupLayout()
        setupObservers()
    }

    private func setupSelf() {
        let pumpIdentifier = viewModel.fuelingProcess.selectedPump?.identifier ?? ""
        title = "Pump No. \(pumpIdentifier)"
        view.backgroundColor = .white
    }

    private func setupElements() {
        [summaryItemsView, payButton, loadingSpinner].forEach { view.addSubview($0) }
        payButton.setTitle(viewModel.fuelingProcess.isPostPay ? "Pay" : "Authorize", for: .normal)
    }

    private func setupLayout() {
        let constraints = [
            summaryItemsView.topAnchor.constraint(equalTo: view.topAnchor),
            summaryItemsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            summaryItemsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            summaryItemsView.bottomAnchor.constraint(equalTo: payButton.topAnchor, constant: -20),

            payButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            payButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -80),
            payButton.widthAnchor.constraint(equalToConstant: 180),
            payButton.heightAnchor.constraint(equalToConstant: 60),

            loadingSpinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingSpinner.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loadingSpinner.heightAnchor.constraint(equalToConstant: 50),
            loadingSpinner.heightAnchor.constraint(equalToConstant: 50)
        ]

        NSLayoutConstraint.activate(constraints)
    }

    private func setupObservers() {
        viewModel.summaryItems.observe(receiver: self) { [weak self] summaryItems in
            guard let summaryItems = summaryItems else { return }
            self?.summaryItemsView.updateSummaryItems(summaryItems)
        }

        viewModel.showPaymentAuthorizationAlert.observe(receiver: self) { [weak self] showPaymentAuthorizationAlert in
            guard let showPaymentAuthorizationAlert = showPaymentAuthorizationAlert, showPaymentAuthorizationAlert else { return }
            self?.showPaymentAuthorizationAlert()
        }

        viewModel.didFinishPaymentProcess.observe(receiver: self) { [weak self] paymentSuccessData in
            guard let self = self, let paymentSuccessData = paymentSuccessData else { return }
            let fuelingProcess = self.viewModel.fuelingProcess

            if fuelingProcess.isPostPay {
                let paymentSuccessViewModel = SuccessViewModelImplementation(paymentSuccessData: paymentSuccessData)
                let paymentSuccessViewController = SuccessViewController(viewModel: paymentSuccessViewModel)
                self.navigationController?.setViewControllers([paymentSuccessViewController], animated: true)
            } else if fuelingProcess.isPreAuth {
                let pumpStatusViewModel = PumpStatusViewModelImplementation(fuelingProcess: fuelingProcess)
                let pumpStatusViewController = PumpStatusViewController(viewModel: pumpStatusViewModel)
                self.navigationController?.pushViewController(pumpStatusViewController, animated: true)
            }
        }

        viewModel.errorMessage.observe(receiver: self) { [weak self] errorMessage in
            guard let errorMessage = errorMessage else { return }
            self?.presentPaymentFailedAlert(message: errorMessage)
        }

        viewModel.isLoading.observe(receiver: self) { [weak self] isLoading in
            self?.loadingSpinner.isLoading = isLoading ?? false
        }
    }

    private func showPaymentAuthorizationAlert() {
        var alertActions: [UIAlertAction] = [
            .init(title: "PIN", style: .default, handler: { [weak self] _ in
                self?.showPaymentAuthorizationInputAlert(type: .pin)
            }),
            .init(title: "Password", style: .default, handler: { [weak self] _ in
                self?.showPaymentAuthorizationInputAlert(type: .password)
            })
        ]

        if IDKit.isBiometricAuthenticationEnabled() {
            alertActions.append(
                .init(title: "Biometry", style: .default, handler: { [weak self] _ in
                    self?.viewModel.handlePaymentAuthorization(type: .biometry, input: nil)
                })
            )
        }

        alertActions.append(.init(title: "Cancel", style: .cancel, handler: nil))

        let alert = UIAlertController.actionsAlert(title: "Payment authorization",
                                                   message: nil,
                                                   actions: alertActions)
        present(alert, animated: true)
    }

    private func showPaymentAuthorizationInputAlert(type: PaymentAuthorizationType) {
        let actionMessage = type == .pin ? "Please enter your PACE PIN" : "Please enter your PACE ID password"
        let alert = UIAlertController(title: nil, message: actionMessage, preferredStyle: .alert)

        alert.addTextField { textField in
            textField.keyboardType = type == .pin ? .numberPad : .default
            textField.isSecureTextEntry = type == .password
            textField.placeholder = type == .pin ? "PIN" : "Password"
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let authorizeAction = UIAlertAction(title: "Authorize", style: .default) { [weak self] _ in
            let input = alert.textFields?.first?.text
            self?.viewModel.handlePaymentAuthorization(type: type, input: input)
        }

        [cancelAction, authorizeAction].forEach {
            alert.addAction($0)
        }

        present(alert, animated: true)
    }

    private func presentPaymentFailedAlert(message: String) {
        let alert = UIAlertController.retryAlert(title: "Payment Failed",
                                                 message: message,
                                                 retryHandler: { [weak self] in
            self?.viewModel.makePayment()
        }, restartHandler: { [weak self] in
            guard let self = self,
                  let pumpSelectionViewController = self.navigationController?.viewControllers.first(where: { $0 is PumpSelectionViewController }) else { return }
            self.navigationController?.popToViewController(pumpSelectionViewController, animated: true)
        })

        present(alert, animated: true)
    }

    @objc
    private func didTapPayButton() {
        viewModel.makePayment()
    }
}
