//
//  LoginViewController.swift
//  FuelingExampleApp
//
//  Created by PACE Telematics GmbH.
//

import UIKit

class LoginViewController: UIViewController {
    private lazy var loadingSpinner: ActivityIndicatorView = .init()

    private lazy var loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Login", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .regular)
        button.backgroundColor = .blue
        button.addTarget(self, action: #selector(handleLoginTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 8
        return button
    }()

    private let viewModel: LoginViewModel

    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupObserver()
        refreshSession()
    }

    private func setupView() {
        navigationItem.title = "Fueling Example App"

        [loadingSpinner, loginButton].forEach(view.addSubview)

        loadingSpinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loadingSpinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        loadingSpinner.heightAnchor.constraint(equalToConstant: 50).isActive = true
        loadingSpinner.heightAnchor.constraint(equalToConstant: 50).isActive = true

        loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        loginButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40).isActive = true
        loginButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }

    private func setupObserver() {
        viewModel.isLoading.observe(receiver: self) { [weak self] isLoading in
            self?.loadingSpinner.isLoading = isLoading ?? false
        }

        viewModel.errorMessage.observe(receiver: self) { [weak self] errorMessage in
            guard let errorMessage = errorMessage else { return }
            self?.presentErrorAlert(message: errorMessage)
        }

        viewModel.showBiometricAuthenticationAlert.observe(receiver: self) { [weak self] showBiometricAuthenticationAlert in
            guard let showBiometricAuthenticationAlert = showBiometricAuthenticationAlert, showBiometricAuthenticationAlert else { return }
            self?.showBiometricAuthenticationAlert()
        }

        viewModel.didHandleBiometricAuthentication.observe(receiver: self) { [weak self] didHandleBiometricAuthentication in
            guard let didHandleBiometricAuthentication = didHandleBiometricAuthentication, didHandleBiometricAuthentication else { return }
            self?.showGasStationList()
        }
    }

    @objc
    private func handleLoginTapped() {
        viewModel.authorize(presentingViewController: self) { [weak self] errorMessage in
            if let errorMessage = errorMessage {
                self?.presentErrorAlert(message: errorMessage)
            } else {
                self?.askForBiometricAuthentication()
            }
        }
    }

    private func refreshSession() {
        viewModel.refresh { [weak self] errorMessage in
            if let errorMessage = errorMessage {
                self?.presentErrorAlert(message: errorMessage)
            } else {
                self?.askForBiometricAuthentication()
            }
        }
    }

    private func askForBiometricAuthentication() {
        viewModel.askForBiometricAuthentication()
    }

    private func showBiometricAuthenticationAlert() {
        let alert = UIAlertController.actionsAlert(title: "Biometric authentication",
                                                   message: "Do you want to use biometry to authorize your payments?",
                                                   actions: [
                                                    .init(title: "Activate using PIN", style: .default, handler: { [weak self] _ in
                                                        self?.showPaymentAuthorizationInputAlert(type: .pin)
                                                    }),
                                                    .init(title: "Activate using Password", style: .default, handler: { [weak self] _ in
                                                        self?.showPaymentAuthorizationInputAlert(type: .password)
                                                    }),
                                                    .init(title: "No", style: .cancel) { [weak self] _ in
                                                        self?.showGasStationList()
                                                    }
                                                   ])
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

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
            self?.showGasStationList()
        }

        let enableAction = UIAlertAction(title: "Confirm", style: .default) { [weak self] _ in
            let input = alert.textFields?.first?.text
            self?.viewModel.handleBiometricAuthentication(type: type, input: input)
        }

        [cancelAction, enableAction].forEach {
            alert.addAction($0)
        }

        present(alert, animated: true)
    }

    private func showGasStationList() {
        let viewController = GasStationListViewController(viewModel: GasStationListViewModelImplementation())
        navigationController?.setViewControllers([viewController], animated: true)
    }

    private func presentErrorAlert(message: String?) {
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController.errorAlert(message: message)
            self?.present(alert, animated: true)
        }
    }
}
