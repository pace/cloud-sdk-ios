//
//  ActivityIndicatorView.swift
//  FuelingExampleApp
//
//  Created by PACE Telematics GmbH.
//

import UIKit

class ActivityIndicatorView: UIActivityIndicatorView {
    var isLoading: Bool {
        get {
            isAnimating
        }

        set {
            newValue ? startAnimating() : stopAnimating()
        }
    }

    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setup()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        hidesWhenStopped = true
        style = .large
        translatesAutoresizingMaskIntoConstraints = false
    }
}
