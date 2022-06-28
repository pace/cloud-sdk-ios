//
//  SuccessViewController.swift
//  FuelingExampleApp
//
//  Created by PACE Telematics GmbH.
//

import UIKit

class SuccessViewController: UIViewController {
    private let viewModel: SuccessViewModel

    private lazy var summaryItemsView: SummaryItemsView = .init()

    private lazy var okayButton: UIButton = {
        let button = UIButton()
        button.setTitle("Ok", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 24)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .paceBlue
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapOk), for: .touchUpInside)
        return button
    }()

    private var summaryItems: [SummaryItem] = []

    init(viewModel: SuccessViewModel) {
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
        title = "Have a good trip!"
        view.backgroundColor = .white
        navigationItem.hidesBackButton = true
    }

    private func setupElements() {
        [summaryItemsView, okayButton].forEach { view.addSubview($0) }
    }

    private func setupLayout() {
        let constraints = [
            summaryItemsView.topAnchor.constraint(equalTo: view.topAnchor),
            summaryItemsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            summaryItemsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            summaryItemsView.bottomAnchor.constraint(equalTo: okayButton.topAnchor, constant: -20),

            okayButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            okayButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -80),
            okayButton.widthAnchor.constraint(equalToConstant: 180),
            okayButton.heightAnchor.constraint(equalToConstant: 60)
        ]

        NSLayoutConstraint.activate(constraints)
    }

    private func setupObservers() {
        viewModel.summaryItems.observe(receiver: self) { [weak self] summaryItems in
            guard let summaryItems = summaryItems else { return }
            self?.summaryItemsView.updateSummaryItems(summaryItems)
        }
    }

    @objc
    private func didTapOk() {
        let viewController = GasStationListViewController(viewModel: GasStationListViewModelImplementation())
        navigationController?.setViewControllers([viewController], animated: true)
    }
}
