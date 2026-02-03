//
//  SearchCoordinator.swift
//  MiniUpsplash
//
//  Created by Gucci on 2/3/26.
//
import UIKit

final class SearchCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController

        navigationController.tabBarItem = UITabBarItem(title: "검색", image: UIImage(systemName: "sparkle.magnifyingglass"), selectedImage: nil)
    }

    func start() {
        let vc = SearchResultViewController(service: AppCoordinator.service)
        vc.coordinator = self
        navigationController.setViewControllers([vc], animated: false)
    }
    

}
