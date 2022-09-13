//
//  AmountSelectionViewController.swift
//  FuelingExampleApp
//
//  Created by PACE Telematics GmbH.
//

import UIKit

class AmountSelectionViewController: UIViewController {
    private let viewModel: AmountSelectionViewModel

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Please enter the amount you want to fuel"
        return label
    }()

    private lazy var amountTextField: UITextField = {
        let textField = UITextField()
        textField.font = .boldSystemFont(ofSize: 32)
        textField.textAlignment = .center
        textField.layer.cornerRadius = 8
        textField.layer.borderWidth = 2
        textField.backgroundColor = .clear
        textField.layer.borderColor = UIColor.paceBlue.cgColor
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.keyboardType = .numberPad
        textField.text = "120"
        return textField
    }()

    private lazy var currencyLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var continueButton: UIButton = {
        let button = UIButton()
        button.setTitle("Continue", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 24)
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 8
        button.backgroundColor = .paceBlue
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didEnterAmount), for: .touchUpInside)
        return button
    }()

    init(viewModel: AmountSelectionViewModel) {
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

    func setup() {
        setupSelf()
        setupElements()
        setupLayout()
        setupObservers()
    }

    private func setupSelf() {
        title = "Authorization amount"
        view.backgroundColor = .white
        hideKeyboardWhenTapped()
    }

    private func setupElements() {
        [titleLabel, amountTextField, currencyLabel, continueButton].forEach { view.addSubview($0) }
        currencyLabel.text = viewModel.fuelingProcess.currencySymbol
    }

    private func setupLayout() {
        let constraints = [
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            amountTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            amountTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            amountTextField.widthAnchor.constraint(equalToConstant: 120),
            amountTextField.heightAnchor.constraint(equalToConstant: 60),

            currencyLabel.centerYAnchor.constraint(equalTo: amountTextField.centerYAnchor),
            currencyLabel.leftAnchor.constraint(equalTo: amountTextField.rightAnchor, constant: 5),

            continueButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            continueButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -80),
            continueButton.widthAnchor.constraint(equalToConstant: 180),
            continueButton.heightAnchor.constraint(equalToConstant: 60)
        ]

        NSLayoutConstraint.activate(constraints)
    }

    private func setupObservers() {
        viewModel.errorMessage.observe(receiver: self) { [weak self] errorMessage in
            guard let errorMessage = errorMessage else { return }
            self?.presentErrorAlert(message: errorMessage)
        }
    }

    private func presentErrorAlert(message: String) {
        let alert = UIAlertController.errorAlert(message: message)
        present(alert, animated: true)
    }

    @objc
    func didEnterAmount() {
        guard let amountString = amountTextField.text, !amountString.isEmpty else {
            presentErrorAlert(message: "Please enter a valid amount.")
            return
        }

        viewModel.didEnterAmount(amountString)

        let summaryViewModel = SummaryViewModelImplementation(fuelingProcess: viewModel.fuelingProcess)
        let summaryViewController = SummaryViewController(viewModel: summaryViewModel)
        navigationController?.pushViewController(summaryViewController, animated: true)
    }
}
