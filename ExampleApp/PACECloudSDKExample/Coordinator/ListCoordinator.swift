//
//  ListCoordinator.swift
//  PACECloudSDKExample
//
//  Created by Patrick Niepel on 05.11.20.
//

import UIKit

class ListCoordinator: Coordinator {
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController

    private let listViewController: ListViewController

    init() {
        navigationController = UINavigationController()
        listViewController = ListViewController(with: ListViewModel())
    }

    func start() {
        listViewController.tabBarItem = UITabBarItem(title: nil, image: Images.tabBarList.image, selectedImage: Images.tabBarListActive.image)
        listViewController.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        navigationController.pushViewController(listViewController, animated: false)
    }
}
