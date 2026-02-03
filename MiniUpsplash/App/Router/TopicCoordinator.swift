//
//  TopicCoordinator.swift
//  MiniUpsplash
//
//  Created by Gucci on 2/3/26.
//
import UIKit

final class TopicCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController

        navigationController.tabBarItem = UITabBarItem(title: "토픽",
                                                       image: UIImage(systemName: "laser.burst"), selectedImage: nil)
    }

    func start() {
        let vc = TopicViewController(service: AppCoordinator.service)
        vc.coordinator = self
        navigationController.setViewControllers([vc], animated: false)
    }

    func showProfile() {
        // TODO: -
    }

    func showDetail() {
        
    }
}
