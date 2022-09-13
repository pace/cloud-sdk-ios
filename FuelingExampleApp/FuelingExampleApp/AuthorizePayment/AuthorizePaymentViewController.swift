//
//  SelectPumpViewController.swift
//  PACECloudSDKFueling
//
//  Created by Philipp Knoblauch on 28.06.22.
//

import UIKit

class AutorizePaymentViewController: UIViewController {
    let viewModel: GasStationListViewModel

    init(viewModel: GasStationListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        setup()
    }

    func setup() {
        setupElements()
        setupLayout()
    }

    func setupElements() {
//        view.addSubview()

        view.backgroundColor = .green
    }

    func setupLayout() {
//        let constraints = []
//        NSLayoutConstraint.activate(constraints)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
