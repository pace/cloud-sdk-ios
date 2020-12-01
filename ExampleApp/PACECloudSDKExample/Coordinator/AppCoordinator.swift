//
//  AppCoordinator.swift
//  PACECloudSDKExample
//
//  Created by Patrick Niepel on 05.11.20.
//

import UIKit

class AppCoordinator: Coordinator {
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController

    private let tabBarController: UITabBarController

    private let listCoordinator: ListCoordinator
    private let fuelingCoordinator: FuelingCoordinator

    init() {
        self.navigationController = UINavigationController()

        tabBarController = UITabBarController()

        listCoordinator = ListCoordinator()
        fuelingCoordinator = FuelingCoordinator()
    }

    func start() {
        navigationController.isNavigationBarHidden = true
        navigationController.setViewControllers([tabBarController], animated: false)

        let coordinators: [Coordinator] = [listCoordinator, fuelingCoordinator]
        coordinators.forEach { $0.start() }

        tabBarController.viewControllers = coordinators.map { $0.navigationController }
        childCoordinators.append(contentsOf: coordinators)

        setupNavigationBar()
        setupTabBar()
    }
}

extension AppCoordinator {
    private func setupNavigationBar() {
        navigationController.navigationBar.barStyle = .default

        navigationController.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.primary,
            NSAttributedString.Key.font: UIFont.navigationBarFont
        ]

        navigationController.navigationBar.isTranslucent = true
        navigationController.navigationBar.tintColor = UIColor.primary

        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = UIColor.background
            UINavigationBar.appearance().standardAppearance = appearance
        } else {
            navigationController.navigationBar.barTintColor = UIColor.background
        }
    }

    private func setupTabBar() {
        if #available(iOS 13.0, *) {
            let appearance = UITabBarAppearance()

            appearance.backgroundColor = UIColor.background
            appearance.stackedLayoutAppearance.normal.iconColor = UIColor.foreground
            appearance.stackedLayoutAppearance.selected.iconColor = UIColor.brand

            tabBarController.tabBar.standardAppearance = appearance

            tabBarController.tabBar.setNeedsLayout()
        } else {
            tabBarController.tabBar.barTintColor = UIColor.background
            tabBarController.tabBar.tintColor = UIColor.foreground
            tabBarController.tabBar.unselectedItemTintColor = UIColor.brand
        }
    }
}
