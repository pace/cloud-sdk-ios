//
//  DrawerView.swift
//  PACECloudSDKExample
//
//  Created by PACE Telematics GmbH.
//

import Foundation
import PACECloudSDK
import SwiftUI

struct DrawerView<T: DrawerViewModel>: View {
    @ObservedObject private(set) var viewModel: T

    init(viewModel: T) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            NavigationView {
                contentView
                    .navigationTitle("App Drawer")
            }
            RectangularButton(title: "Request AppDrawers", action: viewModel.requestAppDrawers)
                .padding([.leading, .trailing], .defaultPadding)
            Spacer()
                .frame(height: .defaultPadding / 2)
        }
    }

    @ViewBuilder
    var contentView: some View {
        if viewModel.isLoading {
            LoadingSpinner()
        } else if viewModel.didFailDrawers {
            ErrorView()
        } else {
            DrawerViewControllerView(viewModel: viewModel)
        }
    }
}

struct DrawerViewControllerView<T: DrawerViewModel>: UIViewControllerRepresentable {
    @ObservedObject private(set) var viewModel: T

    init(viewModel: T) {
        self.viewModel = viewModel
    }

    func makeUIViewController(context: Context) -> DrawerViewController {
        .init()
    }

    func updateUIViewController(_ uiView: DrawerViewController, context: Context) {
        uiView.inject(viewModel.drawers)
    }
}

class DrawerViewController: UIViewController {
    private lazy var appDrawerContainer: AppKit.AppDrawerContainer = .init()

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    private func setup() {
        appDrawerContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(appDrawerContainer)

        appDrawerContainer.setupContainerView()
        appDrawerContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -150).isActive = true
        appDrawerContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }

    func inject(_ appDrawers: [AppKit.AppDrawer]) {
        view.bringSubviewToFront(appDrawerContainer)
        appDrawerContainer.inject(appDrawers, theme: .light)
    }
}
