//
//  FuelingCoordinator.swift
//  PACECloudSDKExample
//
//  Created by Patrick Niepel on 05.11.20.
//

import UIKit

class FuelingCoordinator: Coordinator {
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController

    private let fuelingViewController: UIViewController

    init() {
        navigationController = UINavigationController()
        fuelingViewController = FuelingViewController()
    }

    func start() {
        fuelingViewController.tabBarItem = UITabBarItem(title: nil, image: Images.tabBarFueling.image, selectedImage: Images.tabBarFuelingActive.image)
        fuelingViewController.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        navigationController.pushViewController(fuelingViewController, animated: false)
    }
}
