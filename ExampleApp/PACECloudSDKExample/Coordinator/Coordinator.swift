//
//  Coordinator.swift
//  PACECloudSDKExample
//
//  Created by Patrick Niepel on 05.11.20.
//

import UIKit

protocol Coordinator {
    var parentCoordinator: Coordinator? { get set }
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }

    func start()
}
